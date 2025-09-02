from __future__ import annotations

import argparse
import datetime
import datetime as dt
import logging
import re
import readline
import sys
import typing
from collections import defaultdict
from collections.abc import Iterable
from subprocess import run

import structlog

from dennich.todo.cmd import today_status
from dennich.todo.models import Todo
from dennich.todo.models import TodoRepo
from dennich.todo.models import get_session
from dennich.todo.models import sort_todos
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
    # TODO: should get the open todos from the server, not accessing them directly via SQL.
    sess = get_session()
    repo = TodoRepo(sess)
    todos = repo.load_todos()
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

    POMODORO_DURATIONS: list[int | str] = [10, 25, 20, 15, 5, 1, 'done', 'edit']
    selection_pomo = selector.select([str(d) for d in POMODORO_DURATIONS])

    match selection_pomo:
        case SelectionExistingItem():
            duration = POMODORO_DURATIONS[selection_pomo.id]
        case SelectionNewItem():
            raise ValueError(f'Unknown pomodoro time: {selection_pomo.text}')
        case SelectionCancelled():
            # by cancelling the pomodoro, we want to simply add the todo
            # without starting a pomodoro
            repo.upsert_todo(todo)
            return 0
        case _:
            typing.assert_never(selection_pomo)

    if duration == 'done':
        logger.debug('Completing todo', todo=todo)
        todo.completed_at = dt.datetime.now()
        todo.order = dt.datetime.now()
        repo.upsert_todo(todo)
    elif duration == 'edit':
        logger.debug('Completing todo', todo=todo)
        with_hashbang = [f'#{tag}' for tag in todo.tags]
        prefilled = ' '.join([' '.join(with_hashbang), todo.name])
        new_name = prefill_input('New todo name: ', prefilled)
        new_todo = Todo.from_text_prompt(new_name)
        todo.name = new_todo.name
        todo.tags = new_todo.tags
        repo.upsert_todo(todo)
    else:
        todo.order = dt.datetime.now()
        repo.upsert_todo(todo)
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


def prefill_input(prompt: str, prefill: str = '') -> str:
    readline.set_startup_hook(lambda: readline.insert_text(prefill))
    try:
        return input(prompt)
    finally:
        readline.set_startup_hook()


def time_report(days: int, chart: bool = False) -> int:
    from rich.console import Console
    from rich.table import Table

    sess = get_session()
    repo = TodoRepo(sess)

    cutoff_date = dt.datetime.now() - dt.timedelta(days=days)
    pomodoros = repo.load_pomodoros_created_after(cutoff_date)

    # Group by date and tag
    daily_tag_minutes: defaultdict[dt.date, defaultdict[str, int]] = defaultdict(
        lambda: defaultdict(int)
    )

    for pomodoro in pomodoros:
        date_key = pomodoro.start_time.date()
        if pomodoro.todo and pomodoro.todo.tags:
            for tag in pomodoro.todo.tags:
                daily_tag_minutes[date_key][tag] += pomodoro.duration
        elif pomodoro.todo and not pomodoro.todo.tags:
            daily_tag_minutes[date_key]['untagged'] += pomodoro.duration

    console = Console()

    # Get all unique tags across all days
    all_tags: set[str] = set()
    for day_data in daily_tag_minutes.values():
        all_tags.update(day_data.keys())
    sorted_tags = sorted(all_tags)

    # Sort dates in descending order (most recent first)
    sorted_dates = sorted(daily_tag_minutes.keys(), reverse=True)

    overall_totals: defaultdict[str, int] = defaultdict(int)

    if chart:
        # Chart view - grouped by tag first, then day
        console.print(f'[bold]Time Spent by Tag per Day (Last {days} days)[/bold]\n')

        # Calculate overall totals and find max value for scaling
        max_minutes = 0
        for date in sorted_dates:
            day_data = daily_tag_minutes[date]
            for tag in sorted_tags:
                minutes = day_data.get(tag, 0)
                overall_totals[tag] += minutes
                max_minutes = max(max_minutes, minutes)

        # Bar chart scale
        bar_width = 40
        scale_factor = bar_width / max_minutes if max_minutes > 0 else 1

        # Create list of all dates in range
        all_dates = []
        current_date = dt.datetime.now().date()
        for i in range(days):
            all_dates.append(current_date - dt.timedelta(days=i))
        all_dates = sorted(all_dates, reverse=True)

        # Group by tag, then show days
        for tag in sorted_tags:
            tag_total = overall_totals[tag]
            if tag_total > 0:
                tag_hours, tag_mins = divmod(tag_total, 60)
                tag_total_str = (
                    f'{tag_hours}h{tag_mins}m' if tag_hours > 0 else f'{tag_mins}m'
                )
                console.print(
                    f'[bold green]#{tag}[/bold green] [yellow]({tag_total_str})[/yellow]'
                )

                for date in all_dates:
                    day_data = daily_tag_minutes.get(date, defaultdict(int))
                    minutes = day_data.get(tag, 0)
                    day_abbrev = date.strftime('%a')

                    if minutes > 0:
                        bar_length = int(minutes * scale_factor)
                        bar = '█' * bar_length
                        hours, mins = divmod(minutes, 60)
                        time_str = f'{hours}h{mins}m' if hours > 0 else f'{mins}m'
                        console.print(
                            f'  [cyan]{date} ({day_abbrev:3})[/cyan] {bar} {time_str}'
                        )
                    else:
                        console.print(
                            f'  [dim cyan]{date} ({day_abbrev:3})[/dim cyan] -'
                        )

                console.print()

    else:
        # Table view (existing code)
        table = Table(title=f'Time Spent by Tag per Day (Last {days} days)')
        table.add_column('Date', style='cyan', no_wrap=True)

        for tag in sorted_tags:
            table.add_column(f'#{tag}', style='green')

        table.add_column('Total', style='yellow', justify='right')

        for date in sorted_dates:
            day_data = daily_tag_minutes[date]
            day_abbrev = date.strftime('%a')
            row = [f'{date} ({day_abbrev})']

            day_total = 0
            for tag in sorted_tags:
                minutes = day_data.get(tag, 0)
                overall_totals[tag] += minutes
                day_total += minutes

                if minutes > 0:
                    hours, mins = divmod(minutes, 60)
                    time_str = f'{hours}h{mins}m' if hours > 0 else f'{mins}m'
                else:
                    time_str = '-'
                row.append(time_str)

            # Add day total
            day_hours, day_mins = divmod(day_total, 60)
            day_total_str = (
                f'{day_hours}h{day_mins}m' if day_hours > 0 else f'{day_mins}m'
            )
            row.append(day_total_str)

            table.add_row(*row)

        # Add totals row
        totals_row = ['[bold]TOTAL[/bold]']
        grand_total = 0
        for tag in sorted_tags:
            minutes = overall_totals[tag]
            grand_total += minutes
            hours, mins = divmod(minutes, 60)
            time_str = (
                f'[bold]{hours}h{mins}m[/bold]'
                if hours > 0
                else f'[bold]{mins}m[/bold]'
            )
            totals_row.append(time_str)

        grand_hours, grand_mins = divmod(grand_total, 60)
        grand_total_str = (
            f'[bold]{grand_hours}h{grand_mins}m[/bold]'
            if grand_hours > 0
            else f'[bold]{grand_mins}m[/bold]'
        )
        totals_row.append(grand_total_str)

        table.add_section()
        table.add_row(*totals_row)

        console.print(table)

    return 0


def main() -> int:
    argv = sys.argv[1:]
    parser = argparse.ArgumentParser(prog='todos')
    subparsers = parser.add_subparsers(dest='command')

    _ = subparsers.add_parser('start-pomodoro')
    today_status_parser = subparsers.add_parser('today-status')
    today_status_parser.add_argument(
        '--format',
        choices=['polybar', 'waybar', 'waybar-json'],
        default='polybar',
        help='Output format (default: polybar)',
    )
    time_report_parser = subparsers.add_parser(
        'time-report', help='Report time spent on tags over X days'
    )
    time_report_parser.add_argument(
        '--days', type=int, default=7, help='Number of days to look back (default: 7)'
    )
    time_report_parser.add_argument(
        '--chart', action='store_true', help='Display as bar chart instead of table'
    )

    selector = Fzf()

    args = parser.parse_args(argv)
    if args.command == 'start-pomodoro':
        start_pomodoro(selector)
        return 0
    elif args.command == 'today-status':
        return today_status.main(args.format)
    elif args.command == 'time-report':
        return time_report(args.days, args.chart)
    elif args.command is None:
        parser.print_help()
        return 0
    else:
        run(['notify-send', 'Unknown command'])
        raise NotImplementedError('unknown command')


if __name__ == '__main__':
    main()
