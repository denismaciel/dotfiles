import asyncio
from typing import Any
from typing import Dict

from fastapi import Depends
from fastapi import FastAPI
from pydantic import BaseModel

from dennich.todo.models import TodoRepo
from dennich.todo.models import get_session
from dennich.todo.pomodoro.notifications import RealNotificationService
from dennich.todo.pomodoro.notifications import RealSoundPlayer
from dennich.todo.pomodoro.service import PomodoroService

app = FastAPI()

# Global service instance for nagging task
_global_service: PomodoroService | None = None

# Configuration constants
NAGGING_INTERVAL_SECONDS = 60
MAX_NUMBER_OF_ZENITY_WINDOWS = 15


class StartPomodoroRequest(BaseModel):
    todo_id: int
    duration: float


def get_global_service() -> PomodoroService:
    """Get or create the global service instance"""
    global _global_service
    if _global_service is None:
        session = get_session()
        repo = TodoRepo(session)
        sound_player = RealSoundPlayer()
        notification_service = RealNotificationService()
        _global_service = PomodoroService(
            repo=repo,
            sound_player=sound_player,
            notification_service=notification_service,
        )
    return _global_service


def get_pomodoro_service() -> PomodoroService:
    """Dependency to get the global PomodoroService instance"""
    return get_global_service()


async def nagging_task() -> None:
    """Background task that nags user when no pomodoro is running"""
    while True:
        try:
            await asyncio.sleep(NAGGING_INTERVAL_SECONDS)

            service = get_global_service()

            # Only nag if no pomodoro is currently running
            if not service.has_running_pomodoro():
                # Check if we're already showing too many notifications
                if (
                    service._notification_service.count_open_notifications()
                    < MAX_NUMBER_OF_ZENITY_WINDOWS
                ):
                    await service._notification_service.show_nagging_notification()

        except Exception:
            # Continue nagging even if there's an error
            pass


@app.on_event('startup')
async def startup_event():
    """Start the nagging task when the server starts"""
    asyncio.create_task(nagging_task())


@app.get('/health')
async def health_check() -> dict[str, str]:
    return {'status': 'ok'}


@app.post('/pomodoro/start')
async def start_pomodoro(
    request: StartPomodoroRequest,
    service: PomodoroService = Depends(get_pomodoro_service),
) -> Dict[str, Any]:
    return await service.start_pomodoro(request.todo_id, request.duration)


@app.get('/pomodoro/status')
async def get_pomodoro_status(
    service: PomodoroService = Depends(get_pomodoro_service),
) -> Dict[str, Any]:
    return await service.get_status()


@app.delete('/pomodoro/cancel')
async def cancel_pomodoro(
    service: PomodoroService = Depends(get_pomodoro_service),
) -> Dict[str, Any]:
    return await service.cancel_pomodoro()
