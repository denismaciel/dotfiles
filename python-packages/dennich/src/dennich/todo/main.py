from __future__ import annotations

import argparse
import datetime
import datetime as dt
import enum
import itertools
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


def report(since: int, report_type: str) -> int:
    from rich.console import Console
    from rich.table import Table
    import polars as pl

    console = Console()

    today = dt.datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    start_date = today - dt.timedelta(days=since)
    range = pl.date_range(start_date, today, dt.timedelta(days=1), eager=True)

    pomodoros = load_pomodoros_created_after(get_session(), start_date)

    tags = [p.todo.tags for p in pomodoros]
    tags_set = set(itertools.chain.from_iterable(tags))
    df = (
        pl.DataFrame(
            {
                'start_time': [p.start_time for p in pomodoros],
                'end_time': [p.end_time for p in pomodoros],
                'duration': [p.duration for p in pomodoros],
                'todo': [p.todo.name for p in pomodoros],
                'todo_id': [p.todo.id for p in pomodoros],
                'tags': tags,
            }
        )
        .with_columns(
            start_time=pl.col('start_time').cast(pl.Datetime),
            end_time=pl.col('end_time').cast(pl.Datetime),
            start_date=pl.col('start_time').cast(pl.Date),
            end_date=pl.col('end_time').cast(pl.Date),
            duration=pl.duration(minutes=pl.col('duration')),
        )
        .with_columns(
            pl.when(pl.col('duration') < pl.col('end_time') - pl.col('start_time'))
            .then(pl.col('duration'))
            .otherwise(pl.col('end_time') - pl.col('start_time'))
            .alias('duration')
        )
    )

    to_extend = pl.DataFrame(
        list({'start_date': d, 'tag': t} for d, t in itertools.product(range, tags_set))
    ).with_columns(start_date=pl.col('start_date').cast(pl.Date).cast(str))

    tag_per_day = (
        df.with_columns(tag=pl.col('tags').explode())
        .groupby(['tag', 'start_date'])
        .agg(pl.sum('duration').alias('duration'))
        .filter(pl.col('tag').is_not_null())
        .with_columns(start_date=pl.col('start_date').cast(str))
        .join(
            to_extend,
            on=['start_date', 'tag'],
            how='outer',
        )
        .sort(by=['tag', 'start_date'])
        .with_columns(
            duration=pl.when(
                pl.col('duration').is_null(),
            )
            .then(pl.duration(minutes=0))
            .otherwise(pl.col('duration')),
        )
        .with_columns(
            start_date=pl.col('start_date_right'),
            tag=pl.col('tag_right'),
        )
    )

    wide = (
        tag_per_day.filter(pl.col('tag').is_in(['recap', 'biz']))
        .sort(by='start_date')
        .pivot(
            values='duration',
            columns='tag',
            index='start_date',
            aggregate_function='sum',
        )
    )

    tbl = Table(title='🏷  Tag per day')
    tbl.add_column('date')
    tbl.add_column('re:cap')
    tbl.add_column('biz')
    for row in wide.rows(named=True):
        recap = row.get('recap') or dt.timedelta()
        biz = row.get('biz') or dt.timedelta()

        tbl.add_row(
            str(row['start_date']),
            convert_timedelta_to_human_readable(recap),
            convert_timedelta_to_human_readable(biz),
        )

    console.print(tbl)
    return 0


def clean_description(name: str, patterns: tuple[str, ...]) -> str:
    for p in patterns:
        name = name.replace(p, '')
    return name.strip()


class ReportType(enum.StrEnum):
    tag_per_day = 'tag-per-day'
    todos = 'todos'
    tags = 'tags'


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
        return report(since=args.since, report_type=args.report_type)
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
    if hours == 0 and minutes == 0:
        return '-'
    return f'{int(hours)}h {int(minutes)}m'


if __name__ == '__main__':
    main()
