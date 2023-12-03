import argparse

import structlog
from dennich.todo.pomodoro.client import Client
from dennich.todo.pomodoro.server import serve

logger = structlog.stdlib.get_logger()


def start_server() -> None:
    serve()


def main() -> int:
    client = Client()

    parser = argparse.ArgumentParser(description='Pomodoro CLI Client')
    subparsers = parser.add_subparsers(dest='command', required=True)

    # Start command
    start_parser = subparsers.add_parser('start', help='start a new Pomodoro task')
    start_parser.add_argument('todo_id', type=int, help='ID of the Todo to start')
    start_parser.add_argument(
        'duration', type=float, help='Duration of the task in minutes'
    )

    # Status command
    subparsers.add_parser('status', help='get the current Pomodoro task status')

    # Cancel command
    subparsers.add_parser('cancel', help='cancel the current Pomodoro task')

    # Start server command
    subparsers.add_parser('start-server', help='start the Pomodoro server')

    args = parser.parse_args()

    if args.command == 'start':
        response = client.start_pomodoro(args.todo_id, args.duration)
        print(response)
    elif args.command == 'status':
        response = client.get_status()
        print(response)
    elif args.command == 'cancel':
        response = client.cancel_pomodoro()
        print(response)
    elif args.command == 'start-server':
        start_server()
    elif args.command is None:
        parser.print_help()
    else:
        raise NotImplementedError('Unknown command')

    return 0
