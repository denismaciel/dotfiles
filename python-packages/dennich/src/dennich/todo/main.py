from __future__ import annotations

import argparse
import datetime
import datetime as dt
import enum
import logging
import re
import readline
import sys
import typing
from collections.abc import Iterable
from subprocess import run

import structlog

from dennich.todo.cmd import today_status
from dennich.todo.models import get_session
from dennich.todo.models import load_todos
from dennich.todo.models import sort_todos
from dennich.todo.models import Todo
from dennich.todo.models import upsert_todo
from dennich.todo.pomodoro.client import Client
from dennich.todo.select import Fzf
from dennich.todo.select import SelectionCancelled
from dennich.todo.select import SelectionExistingItem
from dennich.todo.select import SelectionNewItem
from dennich.todo.select import Selector


RE_DURATION = re.compile(r'duration=\d+')
RE_DESCRIPTION = re.compile(r'description="?.+"?')


structlog.configure(
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
)
logger = structlog.stdlib.get_logger()


def render_tags(todo: Todo, pad: int) -> str:
    if len(todo.tags) == 0:
        return '.' * pad
    return ' '.join(f'#{tag}' for tag in todo.tags).ljust(pad, '.')


def render_todos(todos: list[Todo]) -> Iterable[tuple[Todo, str]]:
    """
    Render todos as strings to be selected with fzf.
    """
    # Find out longest tag string to left pad remaing tags
    rendered_tags = [render_tags(t, 0) for t in todos]
    max_len = max(len(rt) for rt in rendered_tags)

    for todo in todos:
        rendered_tag = render_tags(todo, max_len + 3)
        yield todo, rendered_tag + ' ' + todo.name


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
    todos = sort_todos(todos)
    rendered = list(render_todos(todos))
    selection = selector.select([todo_str for _, todo_str in rendered], prompt='🍅')

    match selection:
        case SelectionNewItem():
            todo = Todo.from_text_prompt(selection.text)
            logger.debug('Adding new todo', todo=todo)
        case SelectionExistingItem():
            todo = todos[selection.id]
            logger.debug('Selecting existing todo', todo=todo)
        case SelectionCancelled():
            return 0
        case _:
            typing.assert_never(selection)

    POMODORO_DURATIONS = [10, 25, 20, 15, 5, 1, 'done', 'edit']
    selection_pomo = selector.select([str(d) for d in POMODORO_DURATIONS])

    match selection_pomo:
        case SelectionExistingItem():
            duration = POMODORO_DURATIONS[selection_pomo.id]
        case SelectionNewItem():
            raise ValueError(f'Unknown pomodoro time: {selection_pomo.text}')
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
    elif duration == 'edit':
        logger.debug('Completing todo', todo=todo)
        with_hashbang = [f'#{tag}' for tag in todo.tags]
        prefilled = ' '.join([' '.join(with_hashbang), todo.name])
        new_name = prefill_input('New todo name: ', prefilled)
        new_todo = Todo.from_text_prompt(new_name)
        todo.name = new_todo.name
        todo.tags = new_todo.tags
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


def clean_description(name: str, patterns: tuple[str, ...]) -> str:
    for p in patterns:
        name = name.replace(p, '')
    return name.strip()


class ReportType(enum.StrEnum):
    tag_per_day = 'tag-per-day'
    todos = 'todos'
    tags = 'tags'


def prefill_input(prompt, prefill=''):
    readline.set_startup_hook(lambda: readline.insert_text(prefill))
    try:
        return input(prompt)
    finally:
        readline.set_startup_hook()


def main() -> int:
    argv = sys.argv[1:]
    parser = argparse.ArgumentParser(prog='todos')
    subparsers = parser.add_subparsers(dest='command')

    sp_report = subparsers.add_parser('report')
    sp_report.add_argument('--since', type=int, default=7)
    sp_report.add_argument(
        '--report-type', choices=list(ReportType), default=ReportType.tag_per_day
    )

    _ = subparsers.add_parser('start-pomodoro')
    _ = subparsers.add_parser('today-status')

    selector = Fzf()

    args = parser.parse_args(argv)
    if args.command == 'start-pomodoro':
        start_pomodoro(selector)
        return 0
    elif args.command == 'report':
        from dennich.todo.report import report

        return report(since=args.since, report_type=args.report_type)
    elif args.command == 'today-status':
        return today_status.main()
    elif args.command is None:
        parser.print_help()
        return 0
    else:
        run(['notify-send', 'Unknown command'])
        raise NotImplementedError('unknown command')


if __name__ == '__main__':
    main()
