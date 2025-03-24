import asyncio
import atexit
import datetime as dt
import getpass
import json
import os
import socket
import subprocess
import typing
from dataclasses import dataclass
from typing import Any

import structlog

from dennich.todo.config import load_config
from dennich.todo.models import ErrorResponse
from dennich.todo.models import get_session
from dennich.todo.models import GetStatusResponse
from dennich.todo.models import Pomodoro
from dennich.todo.models import ReqCancelPomdoro
from dennich.todo.models import ReqStartPomdoro
from dennich.todo.models import ReqStatusPomdoro
from dennich.todo.models import Request
from dennich.todo.models import Response
from dennich.todo.models import Todo
from dennich.todo.models import TodoRepo


log = structlog.get_logger()

MAX_NUMBER_OF_ZENITY_WINDOWS = 15
NAGGING_INTERVAL_SECONDS = 60


@dataclass
class RunningPomodoro:
    asyncio_task: asyncio.Task[None]
    pomodoro: Pomodoro
    todo: Todo


RUNNING: RunningPomodoro | None = None


async def pomodoro_task(repo: TodoRepo, pomodoro: Pomodoro) -> None:
    await asyncio.sleep(pomodoro.duration * 60)
    pomodoro.end_time = dt.datetime.now()
    repo.create_pomodoro(pomodoro)

    update_running(None)
    proc = subprocess.run(
        [
            '/etc/profiles/per-user/denis/bin/mpv',
            '/home/denis/dotfiles/scripts/assets/win95.ogg',
        ],
        capture_output=True,
    )
    log.info(
        'Pomodoro completed.',
        alarm_stderr=proc.stderr.decode('utf-8'),
        alarm_stdout=proc.stdout.decode('utf-8'),
    )


def respond(response: Any, client_socket: socket.socket) -> None:
    client_socket.sendall(json.dumps(response).encode('utf-8'))


def update_running(new: RunningPomodoro | None) -> None:
    global RUNNING
    RUNNING = new


async def start_pomodoro_task(
    repo: TodoRepo, todo_id: int, duration: float
) -> Response:
    todo = repo.load_todo_by_id(todo_id)
    msg = ''
    # Cancel previous Pomodoro task if running
    if RUNNING:
        RUNNING.asyncio_task.cancel()
        msg = f'Canceled pomodoro for todo "{RUNNING.todo}".'
        cancelled_pomodoro = RUNNING.pomodoro
        cancelled_pomodoro.end_time = dt.datetime.now()
        repo.create_pomodoro(cancelled_pomodoro)

    pomo = Pomodoro(
        start_time=dt.datetime.now(),
        end_time=None,
        duration=duration,
        todo_id=todo.id,
    )
    asyncio_task = asyncio.create_task(pomodoro_task(repo, pomo))
    update_running(RunningPomodoro(asyncio_task, pomo, todo))
    return Response(
        status_code=200,
        message=msg + f'Started pomodoro for todo: {todo}',
    )


async def get_status(repo: TodoRepo) -> GetStatusResponse | ErrorResponse:
    if RUNNING:
        remaining_time = (
            RUNNING.pomodoro.duration * 60
            - (dt.datetime.now() - RUNNING.pomodoro.start_time).total_seconds()
        )

        todo = repo.load_todo_by_id(RUNNING.todo.id)

        # Sum the time of all the pomodoros for the task
        spent_time = 0
        for p in todo.pomodoros:
            # Report only the time spent today
            if p.end_time is not None and p.start_time.date() == dt.date.today():
                spent_time += (p.end_time - p.start_time).total_seconds()

        return GetStatusResponse(
            status_code=200,
            remaining_time=remaining_time,
            task_name=RUNNING.todo.name,
            task_id=RUNNING.todo.id,
            task_time_spent=spent_time,
        )
    else:
        return ErrorResponse(status_code=404, message='No Pomodoro task is running.')


async def cancel_pomodoro_task() -> Response:
    if RUNNING:
        response = f'Canceled: {RUNNING.todo}'
        RUNNING.asyncio_task.cancel()
        update_running(None)
    else:
        response = 'No Pomodoro task is running to cancel.'

    return Response(
        status_code=200,
        message=response,
    )


@dataclass
class Server:
    port: int
    repo: TodoRepo

    async def serve(self) -> None:
        socket_server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        socket_server.bind(('0.0.0.0', self.port))
        atexit.register(socket_server.close)
        socket_server.listen(5)
        socket_server.setblocking(False)

        _nag_task = asyncio.create_task(nag())

        loop = asyncio.get_event_loop()
        while True:
            client_socket, _ = await loop.sock_accept(socket_server)
            loop.create_task(self._handle_client(loop, client_socket))

    async def _handle_client(
        self, loop: asyncio.AbstractEventLoop, client_socket: socket.socket
    ) -> None:
        try:
            request_data = await loop.sock_recv(client_socket, 1024)
            request: Request = json.loads(request_data.decode('utf-8'))

            log.info('Received request.', request=request)

            match request:
                case {'action': 'start'}:
                    request = typing.cast(
                        ReqStartPomdoro, request
                    )  # only necessary for mypy, pyright gets it
                    respond(
                        await start_pomodoro_task(
                            self.repo, request['todo_id'], request['duration']
                        ),
                        client_socket,
                    )
                case {'action': 'status'}:
                    request = typing.cast(
                        ReqStatusPomdoro, request
                    )  # only necessary for mypy, pyright gets it
                    respond(await get_status(self.repo), client_socket)
                case {'action': 'cancel'}:
                    request = typing.cast(
                        ReqCancelPomdoro, request
                    )  # only necessary for mypy, pyright gets it
                    respond(await cancel_pomodoro_task(), client_socket)
                case _:
                    response = Response(status_code=400, message='Invalid request.')
                    respond(response, client_socket)
        except Exception as e:
            log.exception('Error while handling client request.', exc_info=e)
        finally:
            client_socket.close()


def count_zenity_notifications() -> int:
    try:
        # Path to the /proc directory where process information is kept
        proc_dir = '/proc'

        # List all entries in the /proc directory (these are process IDs or other system files)
        dirs = [d for d in os.listdir(proc_dir) if d.isdigit()]

        zenity_count = 0
        for pid in dirs:
            try:
                cmd_path = os.path.join(proc_dir, pid, 'cmdline')
                with open(cmd_path) as f:
                    cmdline = f.read()
                    if 'zenity' in cmdline:
                        zenity_count += 1
            except (FileNotFoundError, ProcessLookupError):
                # The process might have ended before we could read its cmdline
                continue

        return zenity_count
    except Exception as e:
        log.error(f'An error occurred: {e}')
        return 0


async def nag() -> None:
    while True:
        log.info('Will I nag?', running_task=RUNNING)
        await asyncio.sleep(NAGGING_INTERVAL_SECONDS)
        if RUNNING is None:
            log.info('Nagging for Pomodoro')

            zenity_windows = count_zenity_notifications()
            log.info(
                'Zenity windows open',
                zenity_windows=zenity_windows,
                max_number_of_zenity_windows=MAX_NUMBER_OF_ZENITY_WINDOWS,
            )
            if zenity_windows <= MAX_NUMBER_OF_ZENITY_WINDOWS:
                try:
                    cmd = [
                        '/etc/profiles/per-user/denis/bin/zenity',
                        '--error',
                        '--text',
                        "'Track your time!'",
                    ]
                    await asyncio.create_subprocess_shell(
                        ' '.join(cmd),
                        stdout=asyncio.subprocess.PIPE,
                        stderr=asyncio.subprocess.PIPE,
                    )
                except Exception as e:
                    log.error(f'Error executing zenity command: {e}')
            else:
                log.info('Not nagging, too many Zenity windows open.')


def main() -> int:
    user = getpass.getuser()
    log.info(
        f'Starting Pomodoro server for user {user}.',
        max_number_of_zenity_windows=MAX_NUMBER_OF_ZENITY_WINDOWS,
    )

    config = load_config()

    session = get_session()
    repo = TodoRepo(session)
    server = Server(config.port, repo)
    try:
        asyncio.run(server.serve())
    except KeyboardInterrupt:
        print('shutting down')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
