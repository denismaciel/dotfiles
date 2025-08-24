from typing import Any

import httpx


class HttpxClient:
    def __init__(self, base_url: str = 'http://localhost:8000') -> None:
        self.base_url = base_url

    async def health_check(self) -> dict[str, str]:
        async with httpx.AsyncClient() as client:
            response = await client.get(f'{self.base_url}/health')
            response.raise_for_status()
            return response.json()

    async def start_pomodoro(self, todo_id: int, duration: float) -> dict[str, Any]:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f'{self.base_url}/pomodoro/start',
                json={'todo_id': todo_id, 'duration': duration},
            )
            response.raise_for_status()
            return response.json()

    async def get_status(self) -> dict[str, Any]:
        async with httpx.AsyncClient() as client:
            response = await client.get(f'{self.base_url}/pomodoro/status')
            response.raise_for_status()
            return response.json()

    async def cancel_pomodoro(self) -> dict[str, Any]:
        async with httpx.AsyncClient() as client:
            response = await client.delete(f'{self.base_url}/pomodoro/cancel')
            response.raise_for_status()
            return response.json()
