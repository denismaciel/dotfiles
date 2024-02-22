import json
import socket
from typing import Any

import structlog
from dennich.todo.models import ReqCancelPomdoro
from dennich.todo.models import ReqStartPomdoro
from dennich.todo.models import ReqStatusPomdoro
from dennich.todo.models import Request

logger = structlog.stdlib.get_logger()


PORT_PYTHON = 12347
PORT_GO = 12350
PORT = PORT_PYTHON


class Client:
    def __init__(self) -> None:
        self.server_address = ('127.0.0.1', PORT)

    def send_command_to_server(self, request: Request) -> dict[str, Any]:
        # logger.debug('Sending request to server', request=request)
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
            client_socket.connect(self.server_address)
            client_socket.sendall(json.dumps(request).encode('utf-8'))
            response = client_socket.recv(1024).decode('utf-8')
            return json.loads(response)  # type: ignore

    def start_pomodoro(self, todo_id: int, duration: float) -> dict[str, Any]:
        request = ReqStartPomdoro(action='start', todo_id=todo_id, duration=duration)
        return self.send_command_to_server(request)

    def get_status(self) -> dict[str, Any]:
        request = ReqStatusPomdoro(action='status')
        return self.send_command_to_server(request)

    def cancel_pomodoro(self) -> dict[str, Any]:
        request = ReqCancelPomdoro(action='cancel')
        return self.send_command_to_server(request)
