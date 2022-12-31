from __future__ import annotations

import argparse
import datetime as dt
import enum
import json
import re
import sys
import tempfile
from subprocess import run
from typing import Callable
from typing import Iterable
from typing import Literal
from typing import Optional

from pydantic import BaseModel
from pydantic import Field

TODO_FILE_JSONL = '/home/denis/Sync/Notes/Current/todo.jsonlines'
DONE_FILE_JSONL = '/home/denis/Sync/Notes/Current/done.jsonlines'
TODO_FILE = '/home/denis/Sync/Notes/Current/todo.md'
DONE_FILE = '/home/denis/Sync/Notes/Current/done.md'
POMODORO_HISTORY_FILE = '/home/denis/.pomodoro/history'
POMODORO_BIN = '/home/denis/bin/pomodoro'
RE_DURATION = re.compile(r'duration=\d+')
RE_DESCRIPTION = re.compile(r'description=".+"')

RE_TAG = re.compile(r'#[\w,-]+')


def find_tags(s: str) -> list[str]:
    return [tag.replace('#', '') for tag in RE_TAG.findall(s)]


class TodoStatus(str, enum.Enum):
    ACTIVE = 'active'
    DONE = 'done'


class TodoType(str, enum.Enum):
    TODO = 'todo'
    HABIT = 'habit'


class Todo(BaseModel):
    name: str
    status: TodoStatus = TodoStatus.ACTIVE
    type: TodoType = TodoType.TODO
    tags: Optional[list[str]] = None
    created_at: dt.datetime = Field(default_factory=dt.datetime.now)
    completed_at: Optional[dt.datetime] = None

    @classmethod
    def from_jsonl(cls, line: str) -> Todo:
        return Todo(**json.loads(line))

    @classmethod
    def from_text_prompt(cls, prompt: str) -> Todo:

        if prompt.strip() == '':
            return Todo(name='')

        tags = find_tags(prompt)

        words = prompt.split()
        # filter tags from words
        name = ' '.join(w.strip() for w in words if not w.startswith('#'))

        return Todo(
            name=name,
            tags=tags,
            type=TodoType.TODO,
            status=TodoStatus.ACTIVE,
        )

    def __str__(self):
        tags_str = ''
        if self.tags is not None:
            tags_str = ' '.join(f'#{tag}' for tag in self.tags)
        return ' '.join([self.type.value.upper(), self.name, tags_str]).strip()

    @property
    def is_empty(self) -> bool:
        return self.name.strip() == ''


class EmptyTodoError(Exception):
    ...


class CompletedTodoException(Exception):
    ...


def save_todos2(todos: list[Todo], file):
    with open(file, 'w') as f:
        for todo in todos:
            f.write(todo.json())
            f.write('\n')


def select_with_rofi(
    prompt: str,
    items: list[str],
    multi_select: bool = False,
) -> tuple[int, str]:

    if multi_select is True:
        raise NotImplementedError('multi-select is not implemented')

    mutli_select_opt = '-multi-select' if multi_select else ''
    with tempfile.NamedTemporaryFile('w+') as f:
        f.write('\n'.join(items))
        f.flush()
        cmd = f'rofi -dmenu -p "{prompt} > " {mutli_select_opt} -format "i|s" -input {f.name}'
        proc = run(cmd, shell=True, capture_output=True, text=True)

    proc.check_returncode()
    out = parse_rofi(proc.stdout)
    return out


def load_todos2(file: str) -> list[Todo]:
    with open(file, 'r') as f:
        todos = [Todo.from_jsonl(line) for line in f]
    return todos


def write_todo_to_done_file(todo: Todo):
    todo.completed_at = dt.datetime.now()
    with open(DONE_FILE_JSONL, 'a') as f:
        f.write(todo.json())
        f.write('\n')


def complete_todo(
    todo: Todo,
    todos: Iterable[Todo],
    callback: Callable[[Todo], None],
) -> list[Todo]:
    todos = [t for t in todos if t.name != todo.name]
    callback(todo)
    return todos


def determine_action(todo: Todo, todos: list[Todo]) -> Literal['add', 'complete']:
    if todo in todos:
        return 'complete'
    return 'add'


def parse_rofi(out: str) -> tuple[int, str]:
    idx, text = out.split('|')
    return int(idx), text.strip()


def add_or_toggle():
    todos = load_todos2(TODO_FILE_JSONL)
    i, prompt = select_with_rofi('🚀', [str(todo) for todo in todos])

    if i == -1:
        todo = Todo.from_text_prompt(prompt)
    else:
        todo = todos[i]

    # When Esc is pressend in rofi prompt
    if todo.is_empty:
        return

    action = determine_action(todo, todos)
    if action == 'add':
        todos = [todo] + todos
    elif action == 'complete':
        todos = complete_todo(todo, todos, write_todo_to_done_file)
    else:
        raise AssertionError('unknown action')

    save_todos2(todos, TODO_FILE_JSONL)


def move_to_top(todo, todos):
    return [todo] + [t for t in todos if t.name != todo.name]


def start_pomodoro(select: Callable[[list[Todo]], tuple[int, str]]):
    todos = load_todos2(TODO_FILE_JSONL)
    i, prompt = select(todos)

    if i == -1:
        todo = Todo.from_text_prompt(prompt)
    else:
        todo = todos[i]

    if todo.is_empty:
        return

    i, duration = select_with_rofi('', [str(d) for d in [25, 20, 15, 10, 5, 1]])
    if duration.strip() == '':
        return

    if todo.type == TodoType.TODO:
        todos = move_to_top(todo, todos)

    save_todos2(todos, TODO_FILE_JSONL)
    proc = run(
        [
            POMODORO_BIN,
            'start',
            '--wait',
            '--duration',
            duration,
            todo.name,
        ],
        check=True,
        capture_output=True,
    )

    if proc.returncode == 0:
        run(['mpv', '/home/denis/scripts/assets/win95.ogg'])


def report():
    import datetime
    from collections import defaultdict

    def year_week(d: datetime.date) -> str:
        return format(d, '%Y-%W')

    def human_readable(minutes):
        hs, mins = divmod(minutes, 60)
        return f'{hs}h {mins}m'

    today = datetime.date.today()
    minutes_week = defaultdict(int)

    print('-----------------------------')
    print(f'--- Time tracking {year_week(today)} ---')
    print('-----------------------------')

    with open(POMODORO_HISTORY_FILE) as f:
        for i, line in enumerate(f):
            ts_raw, *_ = line.split()
            ts = datetime.datetime.fromisoformat(ts_raw)

            try:
                if year_week(ts) == year_week(today):
                    (dur_raw,) = RE_DURATION.findall(line)
                    duration = int(dur_raw.replace('duration=', ''))

                    (description,) = RE_DESCRIPTION.findall(line)
                    description = description.replace('description=', '')
                    description = clean_description(
                        description, patterns=('TODO', 'HABIT')
                    )
                    description = description.replace('"', '').strip()
                    minutes_week[description] += duration
            except Exception as e:

                print('An error ocurred with log line:', i + 1, '\n', e)
                raise SystemExit(1)

    for desc, dur in sorted(minutes_week.items(), key=lambda x: -x[1]):
        if dur > 30:
            print(human_readable(dur), desc)


def today_status():
    import datetime
    import subprocess
    import sys

    TARGET_MOONS = 4
    FULL_MOON = ''
    HALF_MOON = ''
    EMPTY_MOON = ''
    RED = '%{B#A54242}%{F#C5C8C6}'
    # part_char = [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉"]

    def progress(minutes_today: int) -> str:
        n50, n50_remainder = divmod(minutes_today, 50)
        n25, _ = divmod(n50_remainder, 25)

        if n25 > 1:
            return 'error'

        remaining = TARGET_MOONS - n50 - bool(n50_remainder)
        return ' '.join(
            [
                *(EMPTY_MOON * remaining),
                bool(n50_remainder) * HALF_MOON,
                *(n50 * FULL_MOON),
            ]
        )

    def color(is_running: bool) -> str:
        if is_running:
            return ''

        if datetime.datetime.now().second % 2 == 0:
            return RED

        return ''

    def compute_minutes_today() -> int:
        minutes_today = 0
        with open('/home/denis/.pomodoro/history') as f:
            for _, line in enumerate(f):
                ts_raw, *_ = line.split()

                ts = datetime.datetime.fromisoformat(ts_raw)

                if ts.date() == datetime.date.today():
                    (dur_raw,) = RE_DURATION.findall(line)
                    duration = int(dur_raw.replace('duration=', ''))
                    minutes_today += duration
        return minutes_today

    minutes_today = compute_minutes_today()
    hour_minutes = '{:02d}:{:02d}'.format(*divmod(minutes_today, 60))

    current_pomo_duration = subprocess.run(
        "pomodoro status -f '%!r'",
        shell=True,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()

    description = subprocess.run(
        "pomodoro status -f '%d'",
        shell=True,
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()

    is_running = len(current_pomo_duration) > 3

    if is_running:
        current_pomo_duration = '•' + current_pomo_duration + '•'
    else:
        current_pomo_duration = ''

    sys.stdout.write(
        color(is_running)
        + ' '
        + progress(minutes_today)
        + ' •'
        + hour_minutes
        + '• '
        + clean_description(description, patterns=('TODO', 'HABIT'))
        + ' '
        + '%{F#1EE86F}'
        + current_pomo_duration
    )


def clean_description(name: str, patterns: tuple[str, ...]) -> str:
    for p in patterns:
        name = name.replace(p, '')
    return name.strip()


def main():
    argv = sys.argv[1:]
    parser = argparse.ArgumentParser(prog='todos')
    subparsers = parser.add_subparsers(dest='command')
    _ = subparsers.add_parser('add-todo')
    _ = subparsers.add_parser('start-pomodoro')
    _ = subparsers.add_parser('report')
    _ = subparsers.add_parser('today-status')

    args = parser.parse_args(argv)

    if args.command == 'add-todo':
        add_or_toggle()
    elif args.command == 'start-pomodoro':
        start_pomodoro(
            select=lambda todos: select_with_rofi('🍅', [str(t) for t in todos])
        )
    elif args.command == 'report':
        report()
    elif args.command == 'today-status':
        today_status()
    else:
        run(['notify-send', 'Unknown command'])
        raise NotImplementedError('unknown command')
    return 0


if __name__ == '__main__':
    print(load_todos2(TODO_FILE_JSONL))
