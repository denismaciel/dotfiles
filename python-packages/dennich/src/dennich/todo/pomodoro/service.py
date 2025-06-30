import asyncio
import datetime as dt
from dataclasses import dataclass
from typing import Any
from typing import Dict

from dennich.todo.models import Pomodoro
from dennich.todo.models import Todo
from dennich.todo.models import TodoRepo
from dennich.todo.pomodoro.notifications import NotificationService
from dennich.todo.pomodoro.notifications import SoundPlayer


@dataclass
class RunningPomodoro:
    asyncio_task: asyncio.Task[None]
    pomodoro: Pomodoro
    todo: Todo


class PomodoroService:
    def __init__(
        self,
        repo: TodoRepo,
        sound_player: SoundPlayer,
        notification_service: NotificationService,
    ) -> None:
        self._running: RunningPomodoro | None = None
        self._repo = repo
        self._sound_player = sound_player
        self._notification_service = notification_service

    async def start_pomodoro(self, todo_id: int, duration: float) -> Dict[str, Any]:
        # Load real todo from database
        todo = self._repo.load_todo_by_id(todo_id)

        # Cancel previous pomodoro if running
        msg = ''
        if self._running:
            self._running.asyncio_task.cancel()
            msg = f'Canceled pomodoro for todo "{self._running.todo}". '
            # Save cancelled pomodoro to database
            cancelled_pomodoro = self._running.pomodoro
            cancelled_pomodoro.end_time = dt.datetime.now()
            self._repo.create_pomodoro(cancelled_pomodoro)

        # Create new pomodoro
        pomo = Pomodoro(
            start_time=dt.datetime.now(),
            end_time=None,
            duration=duration,
            todo_id=todo_id,
        )

        # Create pomodoro completion task
        async def pomodoro_task() -> None:
            await asyncio.sleep(duration * 60)
            # Mark pomodoro as completed and save to database
            pomo.end_time = dt.datetime.now()
            self._repo.create_pomodoro(pomo)
            # Play completion sound
            await self._sound_player.play_completion_sound()
            # Clear running state
            self._running = None

        asyncio_task = asyncio.create_task(pomodoro_task())
        self._running = RunningPomodoro(asyncio_task, pomo, todo)

        return {
            'status_code': 200,
            'message': msg + f'Started pomodoro for todo: {todo}',
        }

    def has_running_pomodoro(self) -> bool:
        return self._running is not None

    async def get_status(self) -> Dict[str, Any]:
        if self._running:
            remaining_time = (
                self._running.pomodoro.duration * 60
                - (
                    dt.datetime.now() - self._running.pomodoro.start_time
                ).total_seconds()
            )

            # Format task name with tags like the original server
            task_name = (
                ' '.join([f'[{tag}]' for tag in self._running.todo.tags])
                + ' '
                + self._running.todo.name
            )

            return {
                'status_code': 200,
                'remaining_time': remaining_time,
                'task_name': task_name.strip(),
                'task_id': self._running.todo.id,
                'task_time_spent': 0.0,  # Mock for now
            }
        else:
            return {'status_code': 404, 'message': 'No Pomodoro task is running.'}

    async def cancel_pomodoro(self) -> Dict[str, Any]:
        if self._running:
            response = f'Canceled: {self._running.todo}'
            self._running.asyncio_task.cancel()
            # Save cancelled pomodoro to database
            cancelled_pomodoro = self._running.pomodoro
            cancelled_pomodoro.end_time = dt.datetime.now()
            self._repo.create_pomodoro(cancelled_pomodoro)
            self._running = None
            return {'status_code': 200, 'message': response}
        else:
            return {
                'status_code': 200,
                'message': 'No Pomodoro task is running to cancel.',
            }
