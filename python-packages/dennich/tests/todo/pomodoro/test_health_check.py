import asyncio

import pytest
import uvicorn
from fastapi.testclient import TestClient

import dennich.todo.pomodoro.fastapi_server as server_module
from dennich.todo.pomodoro.fastapi_server import app
from dennich.todo.pomodoro.httpx_client import HttpxClient


@pytest.fixture(autouse=True)
def reset_global_service():
    """Reset the global service before each test"""
    server_module._global_service = None
    yield
    server_module._global_service = None


def test_health_check_endpoint():
    client = TestClient(app)
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json() == {'status': 'ok'}


@pytest.mark.asyncio
async def test_httpx_client_health_check():
    # Start server in background
    config = uvicorn.Config(app, host='127.0.0.1', port=8001, log_level='error')
    server = uvicorn.Server(config)

    # Run server in background task
    server_task = asyncio.create_task(server.serve())

    # Wait a moment for server to start
    await asyncio.sleep(0.1)

    try:
        httpx_client = HttpxClient(base_url='http://127.0.0.1:8001')
        result = await httpx_client.health_check()
        assert result == {'status': 'ok'}
    finally:
        # Shutdown server
        server.should_exit = True
        await server_task


def test_start_pomodoro_endpoint():
    client = TestClient(app)
    response = client.post('/pomodoro/start', json={'todo_id': 1, 'duration': 25.0})
    assert response.status_code == 200
    data = response.json()
    assert data['status_code'] == 200
    assert 'Started pomodoro' in data['message']


@pytest.mark.asyncio
async def test_httpx_client_start_pomodoro():
    # Start server in background
    config = uvicorn.Config(app, host='127.0.0.1', port=8002, log_level='error')
    server = uvicorn.Server(config)

    # Run server in background task
    server_task = asyncio.create_task(server.serve())

    # Wait a moment for server to start
    await asyncio.sleep(0.1)

    try:
        httpx_client = HttpxClient(base_url='http://127.0.0.1:8002')
        result = await httpx_client.start_pomodoro(todo_id=1, duration=25.0)
        assert result['status_code'] == 200
        assert 'Started pomodoro' in result['message']
    finally:
        # Shutdown server
        server.should_exit = True
        await server_task


def test_status_pomodoro_endpoint():
    client = TestClient(app)
    response = client.get('/pomodoro/status')
    assert response.status_code == 200
    # Should return error when no pomodoro is running
    data = response.json()
    assert data['status_code'] == 404
    assert 'No Pomodoro task is running' in data['message']


@pytest.mark.asyncio
async def test_httpx_client_status_pomodoro():
    # Start server in background
    config = uvicorn.Config(app, host='127.0.0.1', port=8003, log_level='error')
    server = uvicorn.Server(config)

    # Run server in background task
    server_task = asyncio.create_task(server.serve())

    # Wait a moment for server to start
    await asyncio.sleep(0.1)

    try:
        httpx_client = HttpxClient(base_url='http://127.0.0.1:8003')
        result = await httpx_client.get_status()
        assert result['status_code'] == 404
        assert 'No Pomodoro task is running' in result['message']
    finally:
        # Shutdown server
        server.should_exit = True
        await server_task


def test_cancel_pomodoro_endpoint():
    client = TestClient(app)
    response = client.delete('/pomodoro/cancel')
    assert response.status_code == 200
    data = response.json()
    assert data['status_code'] == 200
    assert 'No Pomodoro task is running to cancel' in data['message']


@pytest.mark.asyncio
async def test_httpx_client_cancel_pomodoro():
    # Start server in background
    config = uvicorn.Config(app, host='127.0.0.1', port=8004, log_level='error')
    server = uvicorn.Server(config)

    # Run server in background task
    server_task = asyncio.create_task(server.serve())

    # Wait a moment for server to start
    await asyncio.sleep(0.1)

    try:
        httpx_client = HttpxClient(base_url='http://127.0.0.1:8004')
        result = await httpx_client.cancel_pomodoro()
        assert result['status_code'] == 200
        assert 'No Pomodoro task is running to cancel' in result['message']
    finally:
        # Shutdown server
        server.should_exit = True
        await server_task
