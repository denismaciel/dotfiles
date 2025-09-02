import datetime
import json
import re
import subprocess
import sys

from dennich.todo.pomodoro.client import Client

RE_DURATION = re.compile(r'duration=\d+')

TARGET_MOONS = 4
FULL_MOON = ''
HALF_MOON = ''
EMPTY_MOON = ''
RED = '%{B#A54242}%{F#C5C8C6}'


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


def remove_pattern(name: str, patterns: tuple[str, ...]) -> str:
    for p in patterns:
        name = name.replace(p, '')
    return name.strip()


def color(is_running: bool, format_type: str = 'polybar') -> str:
    if is_running:
        return ''

    if format_type == 'waybar':
        return ''  # waybar doesn't support polybar color codes

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


def main(format_type: str = 'polybar') -> int:
    client = Client()
    response = client.get_status()

    if format_type == 'waybar-json':
        if response['status_code'] == 404:
            # Not running - should blink
            output = {
                'text': ' • 󱁆 • ',
                'class': 'pomodoro-idle'
                if datetime.datetime.now().second % 2 == 0
                else 'pomodoro-idle-blink',
            }
        elif response['status_code'] == 200:
            # Running - normal display
            text = (
                response['task_name']
                + ' •'
                + format_seconds_to_minutes(response['remaining_time'])
                + '• ('
                + format_seconds_to_hours_minutes(response['task_time_spent'])
                + ')'
            )
            output = {'text': text, 'class': 'pomodoro-running'}
        else:
            output = {'text': 'error', 'class': 'pomodoro-error'}
        sys.stdout.write(json.dumps(output))
    else:
        # Original polybar/waybar text format
        if response['status_code'] == 404:
            sys.stdout.write(
                color(is_running=False, format_type=format_type) + ' • ' + '󱁆' + ' • '
            )
        elif response['status_code'] == 200:
            sys.stdout.write(
                color(True, format_type=format_type)
                + response['task_name']
                + ' •'
                + format_seconds_to_minutes(response['remaining_time'])
                + '• ('
                + format_seconds_to_hours_minutes(response['task_time_spent'])
                + ')'
            )
    return 0


def format_seconds_to_minutes(seconds: int) -> str:
    minutes, seconds = divmod(seconds, 60)
    return f'{int(minutes):02d}:{int(seconds):02d}'


def format_seconds_to_hours_minutes(seconds: int) -> str:
    minutes, seconds = divmod(seconds, 60)
    hours, minutes = divmod(minutes, 60)
    return f'{int(hours):02d}:{int(minutes):02d}'


def _main() -> int:
    minutes_today = compute_minutes_today()
    hour_minutes = '{}:{}'.format(*divmod(minutes_today, 60))

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
        + remove_pattern(description, patterns=('TODO', 'HABIT'))
        + ' '
        + '%{F#1EE86F}'
        + current_pomo_duration
    )
    return 0
