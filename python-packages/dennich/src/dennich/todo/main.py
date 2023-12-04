from __future__ import annotations

import argparse
import datetime
import datetime as dt
import logging
import re
import sys
import typing
from subprocess import run

import structlog
from dennich.todo.cmd import today_status
from dennich.todo.models import get_session
from dennich.todo.models import load_pomodoros_created_after
from dennich.todo.models import load_todos
from dennich.todo.models import Todo
from dennich.todo.models import upsert_todo
from dennich.todo.pomodoro.client import Client
from dennich.todo.select import Fzf
from dennich.todo.select import SelectionCancelled
from dennich.todo.select import SelectionKind
from dennich.todo.select import SelectionSelected
from dennich.todo.select import Selector

RE_DURATION = re.compile(r'duration=\d+')
RE_DESCRIPTION = re.compile(r'description="?.+"?')


structlog.configure(
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
)
logger = structlog.stdlib.get_logger()


def start_pomodoro(selector: Selector) -> int:
    """
    You can use this function to:

    1. Add a new Todo and immediately start a Pomodoro
    2. Select an existing Todo and start a Pomodoro
    3. Select an existing Todo and mark it as done
    4. Simply add a new Todo without starting a Pomodoro (just press escape when prompted for the duration)
    """
    sess = get_session()
    todos = load_todos(sess)
    selection = selector.select([str(t) for t in todos], prompt='🍅')

    match selection:
        case SelectionSelected(kind=SelectionKind.NEW_ITEM):
            todo = Todo.from_text_prompt(selection.text)
            logger.debug('Adding new todo', todo=todo)
        case SelectionSelected(kind=SelectionKind.EXISIING_ITEM):
            (todo,) = (t for t in todos if str(t) == selection.text)
            logger.debug('Selecting existing todo', todo=todo)
        case SelectionSelected(kind):
            raise ValueError(f'Unhandled selection kind: {kind}')
        case SelectionCancelled():
            return 0
        case _:
            typing.assert_never(selection)

    selection_pomo = selector.select([str(d) for d in [25, 20, 15, 10, 5, 1, 'done']])

    match selection_pomo:
        case SelectionSelected():
            duration = selection_pomo.text
        case SelectionCancelled():
            # by cancelling the pomodoro, we want to simply add the todo
            # without starting a pomodoro
            upsert_todo(sess, todo)
            return 0
        case _:
            typing.assert_never(selection_pomo)

    if duration == 'done':
        logger.debug('Completing todo', todo=todo)
        todo.completed_at = dt.datetime.now()
        todo.order = dt.datetime.now()
        upsert_todo(sess, todo)
    else:
        todo.order = dt.datetime.now()
        upsert_todo(sess, todo)
        client = Client()
        response = client.start_pomodoro(todo.id, int(duration))
        logger.debug('Starting pomodoro', todo=todo, response=response)
    return 0


def year_week(d: datetime.date) -> str:
    return format(d, '%Y-%W')


def report() -> int:
    today = dt.datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    tags = {}
    pomodoros = load_pomodoros_created_after(
        get_session(),
        today
        # - dt.timedelta(days=7),
    )
    for p in pomodoros:
        if not p.todo.tags:
            tags['default'] = (
                tags.get('default', dt.timedelta()) + p.end_time - p.start_time
            )
            continue

        for tag in p.todo.tags:
            tags[tag] = tags.get(tag, dt.timedelta()) + p.end_time - p.start_time

    todos = {}
    for p in pomodoros:
        todos[p.todo.name] = (
            todos.get(p.todo.name, dt.timedelta()) + p.end_time - p.start_time
        )

    print()
    print('--------- Tags 🏷 ----------------')
    for tag, td in sorted(tags.items(), key=lambda x: -x[1]):
        print(f'{tag}: {convert_timedelta_to_human_readable(td)}')

    print()
    print('--------- Todos 💬 ---------------')
    for todo, td in sorted(todos.items(), key=lambda x: -x[1]):
        print(f'{todo}: {convert_timedelta_to_human_readable(td)}')
    return 0


def clean_description(name: str, patterns: tuple[str, ...]) -> str:
    for p in patterns:
        name = name.replace(p, '')
    return name.strip()


def main() -> int:
    argv = sys.argv[1:]
    parser = argparse.ArgumentParser(prog='todos')
    subparsers = parser.add_subparsers(dest='command')
    _ = subparsers.add_parser('report')
    _ = subparsers.add_parser('start-pomodoro')
    _ = subparsers.add_parser('today-status')

    selector = Fzf()

    args = parser.parse_args(argv)

    if args.command == 'start-pomodoro':
        start_pomodoro(selector)
        return 0
    elif args.command == 'report':
        return report()
    elif args.command == 'today-status':
        return today_status.main()
    elif args.command is None:
        parser.print_help()
        return 0
    else:
        run(['notify-send', 'Unknown command'])
        raise NotImplementedError('unknown command')


def convert_timedelta_to_human_readable(td: dt.timedelta) -> str:
    """
    XXh YYm
    """
    minutes = td.total_seconds() / 60
    hours, minutes = divmod(minutes, 60)
    return f'{int(hours)}h {int(minutes)}m'


if __name__ == '__main__':
    main()
