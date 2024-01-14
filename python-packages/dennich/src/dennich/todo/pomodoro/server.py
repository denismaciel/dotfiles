import asyncio
import datetime as dt
import json
import socket
import subprocess
import typing
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any

import structlog
from dennich.todo.models import ErrorResponse
from dennich.todo.models import get_session
from dennich.todo.models import GetStatusResponse
from dennich.todo.models import load_todo_by_id
from dennich.todo.models import Pomodoro
from dennich.todo.models import ReqCancelPomdoro
from dennich.todo.models import ReqStartPomdoro
from dennich.todo.models import ReqStatusPomdoro
from dennich.todo.models import Request
from dennich.todo.models import Response
from dennich.todo.models import Todo


logger = structlog.get_logger()


@dataclass
class RunningPomodoro:
    asyncio_task: asyncio.Task[None]
    pomodoro: Pomodoro
    todo: Todo


RUNNING: RunningPomodoro | None = None


async def pomodoro_task(duration: float, callback: Callable[[], Any]) -> None:
    await asyncio.sleep(duration * 60)
    callback()


def task_completed_callback() -> None:
    assert RUNNING is not None
    logger.info('Pomodoro completed.', todo=RUNNING.todo, pomodoro=RUNNING.pomodoro)
    assert RUNNING is not None

    sess = get_session()
    RUNNING.pomodoro.end_time = dt.datetime.now()
    sess.add(RUNNING.pomodoro)
    sess.commit()
    sess.close()

    update_running(None)

    proc = subprocess.run(
        [
            '/home/denis/.nix-profile/bin/mpv',
            '/home/denis/dotfile/scripts/assets/win95.ogg',
        ],
        capture_output=True,
    )
    logger.info(
        'Pomodoro completed.',
        alarm_stderr=proc.stderr.decode('utf-8'),
        alarm_stdout=proc.stdout.decode('utf-8'),
    )


def respond(response: Any, client_socket: socket.socket) -> None:
    client_socket.sendall(json.dumps(response).encode('utf-8'))


async def handle_client(client_socket: socket.socket) -> None:
    loop = asyncio.get_running_loop()
    try:
        request_data = await loop.sock_recv(client_socket, 1024)
        request: Request = json.loads(request_data.decode('utf-8'))

        logger.info('Received request.', request=request)

        match request:
            case {'action': 'start'}:
                request = typing.cast(
                    ReqStartPomdoro, request
                )  # only necessary for mypy, pyright gets it
                respond(
                    await start_pomodoro_task(request['todo_id'], request['duration']),
                    client_socket,
                )
            case {'action': 'status'}:
                request = typing.cast(
                    ReqStatusPomdoro, request
                )  # only necessary for mypy, pyright gets it
                respond(await get_status(), client_socket)
            case {'action': 'cancel'}:
                request = typing.cast(
                    ReqCancelPomdoro, request
                )  # only necessary for mypy, pyright gets it
                respond(await cancel_pomodoro_task(), client_socket)
            case _:
                response = Response(status_code=400, message='Invalid request.')
                respond(response, client_socket)
                # typing.assert_never(request)

    except Exception as e:
        logger.exception('Error while handling client request.', exc_info=e)
    finally:
        client_socket.close()


def update_running(new: RunningPomodoro | None) -> None:
    global RUNNING
    RUNNING = new


async def start_pomodoro_task(todo_id: int, duration: float) -> Response:
    sess = get_session()
    todo = load_todo_by_id(sess, todo_id)
    response = ''
    # Cancel previous Pomodoro task if running
    if RUNNING:
        RUNNING.asyncio_task.cancel()
        response = f'Canceled pomodoro for todo "{RUNNING.todo}".'
        cancelled_pomodoro = RUNNING.pomodoro
        cancelled_pomodoro.end_time = dt.datetime.now()
        sess.add(RUNNING.pomodoro)
        sess.commit()

    asyncio_task = asyncio.create_task(pomodoro_task(duration, task_completed_callback))
    pomo = Pomodoro(
        start_time=dt.datetime.now(),
        end_time=None,
        duration=duration,
        todo_id=todo.id,
    )

    update_running(RunningPomodoro(asyncio_task, pomo, todo))
    sess.close()
    return Response(
        status_code=200,
        message=response + f'Started pomodoro for todo: {todo}',
    )


async def get_status() -> GetStatusResponse | ErrorResponse:
    if RUNNING:
        remaining_time = (
            RUNNING.pomodoro.duration * 60
            - (dt.datetime.now() - RUNNING.pomodoro.start_time).total_seconds()
        )
        return GetStatusResponse(
            status_code=200,
            remaining_time=remaining_time,
            task_name=RUNNING.todo.name,
            task_id=RUNNING.todo.id,
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


async def server() -> None:
    loop = asyncio.get_running_loop()
    logger.info('Pomodoro server started.')
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind(('0.0.0.0', 12347))
    server_socket.listen(5)
    server_socket.setblocking(False)
    logger.info('Pomodoro server started, waiting for connections...')

    loop.create_task(nag())

    while True:
        client_socket, _ = await loop.sock_accept(server_socket)
        loop.create_task(handle_client(client_socket))


async def nag() -> None:
    while True:
        logger.info('Will I nag?', running_task=RUNNING)
        await asyncio.sleep(60)
        if RUNNING is None:
            logger.info('Nagging for Pomodoro')
            cmd = ['/etc/profiles/per-user/denis/bin/zenity', '--error', '--text', "'Track your time!'"]
            try:
                proc = await asyncio.create_subprocess_shell(
                    ' '.join(cmd),
                    stdout=asyncio.subprocess.PIPE,
                    stderr=asyncio.subprocess.PIPE,
                )

                # Commented out becasue we don't want to wait for the Zenity process to complete.
                # That is, we don't wanna wait for the user to click on the notification.
                # Because we want' to be really annoying an trigger mutliple notifications.
                # Yeah, that's how annoying we are.
                #
                # stdout, stderr = await proc.communicate()
                # logger.info(
                #     'Zenity finished',
                #     nag_stderr=stderr.decode('utf-8'),
                #     nag_stdout=stdout.decode('utf-8'),
                # )
            except Exception as e:
                logger.error(f"Error executing zenity command: {e}")



def serve() -> int:
    loop = asyncio.get_event_loop()
    loop.run_until_complete(server())
    return 0


if __name__ == '__main__':
    raise SystemExit(serve())
