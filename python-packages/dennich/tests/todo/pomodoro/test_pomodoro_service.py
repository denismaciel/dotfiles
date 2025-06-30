import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from dennich.todo.models import Base
from dennich.todo.models import Todo
from dennich.todo.models import TodoRepo
from dennich.todo.pomodoro.notifications import StubNotificationService
from dennich.todo.pomodoro.notifications import StubSoundPlayer
from dennich.todo.pomodoro.service import PomodoroService


@pytest.fixture
def in_memory_db():
    """Create an in-memory SQLite database for testing"""
    engine = create_engine('sqlite:///:memory:')
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    return session


@pytest.fixture
def todo_repo(in_memory_db):
    """Create a TodoRepo with in-memory database"""
    return TodoRepo(in_memory_db)


@pytest.fixture
def sample_todos(todo_repo):
    """Create sample todos in the database"""
    todo1 = Todo(name='Task 1', tags=['work'])
    todo2 = Todo(name='Task 2', tags=['personal'])
    todo_repo.upsert_todo(todo1)
    todo_repo.upsert_todo(todo2)
    return [todo1, todo2]


@pytest.fixture
def stub_sound_player():
    """Create a stub sound player for testing"""
    return StubSoundPlayer()


@pytest.fixture
def stub_notification_service():
    """Create a stub notification service for testing"""
    return StubNotificationService()


@pytest.mark.asyncio
async def test_pomodoro_service_start_with_no_running_pomodoro(
    todo_repo, sample_todos, stub_sound_player, stub_notification_service
):
    service = PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )

    # Start a pomodoro when none is running
    result = await service.start_pomodoro(todo_id=sample_todos[0].id, duration=25.0)

    # Should return success response
    assert result['status_code'] == 200
    assert 'Started pomodoro for todo' in result['message']

    # Service should now have a running pomodoro
    assert service.has_running_pomodoro() is True

    # Should be able to get status of running pomodoro
    status = await service.get_status()
    assert status['status_code'] == 200
    assert 'remaining_time' in status


@pytest.mark.asyncio
async def test_pomodoro_service_start_cancels_existing_pomodoro(
    todo_repo, sample_todos, stub_sound_player, stub_notification_service
):
    service = PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )

    # Start first pomodoro
    result1 = await service.start_pomodoro(todo_id=sample_todos[0].id, duration=25.0)
    assert result1['status_code'] == 200
    assert service.has_running_pomodoro() is True

    # Start second pomodoro - should cancel first one
    result2 = await service.start_pomodoro(todo_id=sample_todos[1].id, duration=30.0)

    # Should return success response with cancel message
    assert result2['status_code'] == 200
    assert 'Canceled pomodoro for todo' in result2['message']
    assert 'Started pomodoro for todo' in result2['message']

    # Should still have a running pomodoro (the new one)
    assert service.has_running_pomodoro() is True

    # Status should show the new pomodoro (second todo)
    status = await service.get_status()
    assert status['status_code'] == 200
    assert status['task_id'] == sample_todos[1].id


@pytest.mark.asyncio
async def test_pomodoro_service_cancel_running_pomodoro(
    todo_repo, sample_todos, stub_sound_player, stub_notification_service
):
    service = PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )

    # Start a pomodoro first
    start_result = await service.start_pomodoro(
        todo_id=sample_todos[0].id, duration=25.0
    )
    assert start_result['status_code'] == 200
    assert service.has_running_pomodoro() is True

    # Cancel the running pomodoro
    cancel_result = await service.cancel_pomodoro()

    # Should return success with cancel message
    assert cancel_result['status_code'] == 200
    assert 'Canceled' in cancel_result['message']

    # Should no longer have a running pomodoro
    assert service.has_running_pomodoro() is False

    # Status should now return no running pomodoro
    status = await service.get_status()
    assert status['status_code'] == 404
    assert 'No Pomodoro task is running' in status['message']


@pytest.mark.asyncio
async def test_pomodoro_service_cancel_when_no_pomodoro_running(
    todo_repo, stub_sound_player, stub_notification_service
):
    service = PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )

    # Try to cancel when no pomodoro is running
    cancel_result = await service.cancel_pomodoro()

    # Should return success but indicate nothing to cancel
    assert cancel_result['status_code'] == 200
    assert 'No Pomodoro task is running to cancel' in cancel_result['message']

    # Should still have no running pomodoro
    assert service.has_running_pomodoro() is False
