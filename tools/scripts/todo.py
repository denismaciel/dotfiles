import argparse
import re
import sys
from subprocess import run

TODO_FILE = "/home/denis/Sync/Notes/Current/todo.md"
DONE_FILE = "/home/denis/Sync/Notes/Current/done.md"
POMODORO_HISTORY_FILE = "/home/denis/.pomodoro/history"
POMODORO_BIN = '/home/denis/bin/pomodoro'
RE_DURATION = re.compile(r"duration=\d+")
RE_DESCRIPTION = re.compile(r'description=".+"')


class EmptyTodoError(Exception):
    ...


class CompletedTodoException(Exception):
    ...


def write_to_file(todos: list[str]):
    with open(TODO_FILE, "w") as f:
        f.write("\n".join(todos))


def select_todo(prompt: str) -> str:
    cmd = f'echo $(cat {TODO_FILE} | grep -v "DONE" | rofi -dmenu -p "{prompt} > ")'
    proc = run(cmd, shell=True, capture_output=True, text=True)
    proc.check_returncode()

    todo = proc.stdout.strip()

    if todo == "":
        raise EmptyTodoError

    return todo


def append_todo(todo):
    with open(TODO_FILE, "r") as f:
        todos = [line.strip() for line in f]

    todo = todo.strip()

    # If todo already exists and is not a habit, move it to the first position.
    if 'HABIT' in todo:
        ...
    elif todo in todos:
        todos.remove(todo)
        todos.insert(0, todo)
    else:
        todos = [f"TODO {todo}"] + todos

    write_to_file(todos)


def prepend_done(todo):
    import datetime

    with open(DONE_FILE, 'r+') as f:
        content = f.read()
        f.seek(0)
        f.write(datetime.datetime.now().isoformat() + ' ' + todo + '\n' + content)


def add_todo():
    with open(TODO_FILE, "r") as f:
        todos = [line.strip() for line in f]

    input_todo = select_todo("TODO")

    # If input_todo already exists, we want to toggle it as complete
    if input_todo in todos:
        i = todos.index(input_todo)
        input_todo = todos.pop(i)
        write_to_file(todos)
        input_todo = input_todo.replace("TODO", "DONE")
        prepend_done(input_todo)
        raise CompletedTodoException(input_todo)

    # Refactor to use append todo
    todos = [f"TODO {input_todo}"] + todos
    write_to_file(todos)


def handle_add_todo():
    try:
        add_todo()
    except EmptyTodoError:
        ...
    except CompletedTodoException as e:
        run(["notify-send", f"Completed {str(e)}"])
    except Exception as e:
        run(["notify-send", f"Failed: {str(e)}"])
    else:
        run(["notify-send", "TODO added successfully"])


def select_duration():
    durations = [25, 20, 15, 10, 5, 1]
    durations_str = r"\n".join(str(d) for d in durations)
    cmd = f"echo '{durations_str}' | rofi -dmenu -p 'Pomdoro'"
    proc = run(cmd, shell=True, check=True, capture_output=True, text=True)
    return proc.stdout.strip()


def start_pomodoro():
    todo = select_todo("🍅")
    duration = select_duration()

    if duration.strip() == "":
        return

    append_todo(todo)
    proc = run(
        [
            POMODORO_BIN,
            "start",
            "--wait",
            "--duration",
            duration,
            todo,
        ],
        check=True,
        capture_output=True,
    )

    if proc.returncode == 0:
        run(['mpv', '/home/denis/scripts/assets/win95.ogg'])


def handle_start_pomodoro():
    try:
        start_pomodoro()
    except EmptyTodoError:
        ...
    except Exception as e:
        run(["notify-send", f"Failed: {str(e)}"])


def report():
    import datetime
    from collections import defaultdict

    def year_week(d: datetime.date) -> str:
        return format(d, "%Y-%W")

    def human_readable(minutes):
        hs, mins = divmod(minutes, 60)
        return f"{hs}h {mins}m"

    today = datetime.date.today()
    minutes_week = defaultdict(int)

    print(f"-----------------------------")
    print(f"--- Time tracking {year_week(today)} ---")
    print(f"-----------------------------")

    with open(POMODORO_HISTORY_FILE) as f:
        for i, line in enumerate(f):
            ts_raw, *_ = line.split()
            ts = datetime.datetime.fromisoformat(ts_raw)

            try:
                if year_week(ts) == year_week(today):
                    (dur_raw,) = RE_DURATION.findall(line)
                    duration = int(dur_raw.replace("duration=", ""))

                    (description,) = RE_DESCRIPTION.findall(line)
                    description = description.replace("description=", "")
                    description = clean_description(description, patterns=('TODO', 'HABIT'))
                    description = description.replace('"', '').strip()
                    minutes_week[description] += duration
            except Exception as e:

                print("An error ocurred with log line:", i + 1, '\n', e)
                raise SystemExit(1)

    for desc, dur in sorted(minutes_week.items(), key=lambda x: -x[1]):
        if dur > 30:
            print(human_readable(dur), desc)


def today_status():
    import datetime
    import subprocess
    import sys

    TARGET_MOONS = 4
    FULL_MOON = ""
    HALF_MOON = ""
    EMPTY_MOON = ""
    RED = "%{B#A54242}%{F#C5C8C6}"
    # part_char = [" ", "▏", "▎", "▍", "▌", "▋", "▊", "▉"]

    def progress(minutes_today: int) -> str:
        n50, n50_remainder = divmod(minutes_today, 50)
        n25, _ = divmod(n50_remainder, 25)

        if n25 > 1:
            return 'error'

        remaining = TARGET_MOONS - n50 - bool(n50_remainder)
        return " ".join(
            [
                *(EMPTY_MOON * remaining),
                bool(n50_remainder) * HALF_MOON,
                *(n50 * FULL_MOON),
            ]
        )

    def color(is_running: bool) -> str:
        if is_running:
            return ""

        if datetime.datetime.now().second % 2 == 0:
            return RED

        return ""

    def compute_minutes_today() -> int:
        minutes_today = 0
        with open("/home/denis/.pomodoro/history") as f:
            for _, line in enumerate(f):
                ts_raw, *_ = line.split()

                ts = datetime.datetime.fromisoformat(ts_raw)

                if ts.date() == datetime.date.today():
                    (dur_raw,) = RE_DURATION.findall(line)
                    duration = int(dur_raw.replace("duration=", ""))
                    minutes_today += duration
        return minutes_today

    minutes_today = compute_minutes_today()
    hour_minutes = "{:02d}:{:02d}".format(*divmod(minutes_today, 60))

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
        current_pomo_duration = "•" + current_pomo_duration + "•"
    else:
        current_pomo_duration = ""

    sys.stdout.write(
        color(is_running)
        + " "
        + progress(minutes_today)
        + " •"
        + hour_minutes
        + "• "
        + clean_description(description, patterns=('TODO', 'HABIT'))
        + " "
        + "%{F#1EE86F}"
        + current_pomo_duration
    )


def clean_description(name: str, patterns: tuple[str, ...]) -> str:
    for p in patterns:
        name = name.replace(p, "")
    return name.strip()


def main():
    argv = sys.argv[1:]
    parser = argparse.ArgumentParser(prog="todos")
    subparsers = parser.add_subparsers(dest="command")
    sp_add_todo = subparsers.add_parser("add-todo")
    sp_start_pomodoro = subparsers.add_parser("start-pomodoro")
    sp_report = subparsers.add_parser("report")
    sp_today_status = subparsers.add_parser("today-status")

    args = parser.parse_args(argv)

    if args.command == "add-todo":
        handle_add_todo()
    elif args.command == "start-pomodoro":
        start_pomodoro()
    elif args.command == "report":
        report()
    elif args.command == 'today-status':
        today_status()
    else:
        run(["notify-send", f"Unknown command"])
        raise NotImplementedError("unknown command")
    return 0
