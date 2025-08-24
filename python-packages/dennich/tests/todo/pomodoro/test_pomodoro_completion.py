import asyncio

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
    engine = create_engine(
        'sqlite:///:memory:', connect_args={'check_same_thread': False}
    )
    Base.metadata.create_all(engine)
    Session = sessionmaker(bind=engine)
    session = Session()
    return session


@pytest.fixture
def todo_repo(in_memory_db):
    """Create a TodoRepo with in-memory database"""
    return TodoRepo(in_memory_db)


@pytest.fixture
def sample_todo(todo_repo):
    """Create a sample todo in the database"""
    todo = Todo(name='Test Task', tags=['work'])
    todo_repo.upsert_todo(todo)
    return todo


@pytest.fixture
def stub_sound_player():
    """Create a stub sound player for testing"""
    return StubSoundPlayer()


@pytest.fixture
def stub_notification_service():
    """Create a stub notification service for testing"""
    return StubNotificationService()


@pytest.mark.asyncio
async def test_pomodoro_completion_plays_sound(
    todo_repo, sample_todo, stub_sound_player, stub_notification_service
):
    """Test that when a pomodoro completes, it plays the completion sound"""
    service = PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )

    # Start a very short pomodoro (0.01 minutes = 0.6 seconds)
    result = await service.start_pomodoro(todo_id=sample_todo.id, duration=0.01)
    assert result['status_code'] == 200
    assert service.has_running_pomodoro() is True

    # Wait for the pomodoro to complete
    await asyncio.sleep(0.8)

    # Sound should have been played
    assert stub_sound_player.play_completion_sound_called is True

    # Pomodoro should no longer be running
    assert service.has_running_pomodoro() is False

    # Completed pomodoro should be saved to database
    pomodoros = todo_repo.load_pomodoros_created_after(sample_todo.created_at)
    assert len(pomodoros) == 1

    completed_pomodoro = pomodoros[0]
    assert completed_pomodoro.todo_id == sample_todo.id
    assert completed_pomodoro.end_time is not None


@pytest.mark.asyncio
async def test_cancelled_pomodoro_is_saved_to_database(
    todo_repo, sample_todo, stub_sound_player, stub_notification_service
):
    """Test that when a pomodoro is cancelled by starting a new one, the cancelled one is saved"""
    service = PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )

    # Create a second todo
    todo2 = Todo(name='Second Task', tags=['personal'])
    todo_repo.upsert_todo(todo2)

    # Start first pomodoro
    result1 = await service.start_pomodoro(todo_id=sample_todo.id, duration=25.0)
    assert result1['status_code'] == 200
    assert service.has_running_pomodoro() is True

    # Wait a bit, then start second pomodoro (should cancel first)
    await asyncio.sleep(0.1)
    result2 = await service.start_pomodoro(todo_id=todo2.id, duration=30.0)

    # Should have cancel message
    assert result2['status_code'] == 200
    assert 'Canceled pomodoro for todo' in result2['message']

    # Should now be running the second pomodoro
    assert service.has_running_pomodoro() is True
    status = await service.get_status()
    assert status['task_id'] == todo2.id

    # Cancelled pomodoro should be saved to database with end_time
    pomodoros = todo_repo.load_pomodoros_created_after(sample_todo.created_at)
    assert len(pomodoros) == 1

    cancelled_pomodoro = pomodoros[0]
    assert cancelled_pomodoro.todo_id == sample_todo.id
    assert cancelled_pomodoro.end_time is not None  # Should be marked as completed
    assert cancelled_pomodoro.duration == 25.0


@pytest.mark.asyncio
async def test_manual_cancel_saves_pomodoro_to_database(
    todo_repo, sample_todo, stub_sound_player, stub_notification_service
):
    """Test that manually cancelling a pomodoro saves it to the database"""
    service = PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )

    # Start pomodoro
    result = await service.start_pomodoro(todo_id=sample_todo.id, duration=25.0)
    assert result['status_code'] == 200
    assert service.has_running_pomodoro() is True

    # Wait a bit, then manually cancel
    await asyncio.sleep(0.1)
    cancel_result = await service.cancel_pomodoro()

    assert cancel_result['status_code'] == 200
    assert 'Canceled' in cancel_result['message']
    assert service.has_running_pomodoro() is False

    # Cancelled pomodoro should be saved to database
    pomodoros = todo_repo.load_pomodoros_created_after(sample_todo.created_at)
    assert len(pomodoros) == 1

    cancelled_pomodoro = pomodoros[0]
    assert cancelled_pomodoro.todo_id == sample_todo.id
    assert cancelled_pomodoro.end_time is not None
    assert cancelled_pomodoro.duration == 25.0
