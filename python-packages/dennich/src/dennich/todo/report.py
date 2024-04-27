import datetime as dt
import itertools

import polars as pl
from dennich.todo.models import get_session
from dennich.todo.models import load_pomodoros_created_after
from dennich.todo.models import Pomodoro
from rich.console import Console
from rich.table import Table


def convert_timedelta_to_human_readable(td: dt.timedelta) -> str:
    """
    XXh YYm
    """
    minutes = td.total_seconds() / 60
    hours, minutes = divmod(minutes, 60)
    if hours == 0 and minutes == 0:
        return '-'
    return f'{int(hours)}h {int(minutes)}m'


def report(since: int, report_type: str) -> int:
    console = Console()

    today = dt.datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    start_date = today - dt.timedelta(days=since)
    range = pl.date_range(start_date, today, dt.timedelta(days=1), eager=True)

    pomodoros = load_pomodoros_created_after(get_session(), start_date)

    def get_tags(pomodoro: Pomodoro) -> list[str]:
        if pomodoro.todo.tags is None:
            raise ValueError(f'Todo {pomodoro.todo.name} has no tags')
        return pomodoro.todo.tags

    tags = [get_tags(p) for p in pomodoros]
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

    date_tag_product = pl.DataFrame(
        list({'start_date': d, 'tag': t} for d, t in itertools.product(range, tags_set))
    ).with_columns(start_date=pl.col('start_date').cast(pl.Date).cast(str))

    tag_per_day = (
        df.with_columns(tag=pl.col('tags').explode())
        .groupby(['tag', 'start_date'])
        .agg(pl.sum('duration').alias('duration'))
        .filter(pl.col('tag').is_not_null())
        .with_columns(start_date=pl.col('start_date').cast(str))
        .join(
            date_tag_product,
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
