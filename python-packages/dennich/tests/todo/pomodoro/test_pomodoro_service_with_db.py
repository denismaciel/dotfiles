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
async def test_pomodoro_service_with_real_todo_from_database(
    todo_repo, sample_todo, stub_sound_player, stub_notification_service
):
    service = PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )

    # Start pomodoro with real todo from database
    result = await service.start_pomodoro(todo_id=sample_todo.id, duration=25.0)

    # Should return success response with real todo name
    assert result['status_code'] == 200
    assert 'Started pomodoro for todo:' in result['message']
    assert 'Test Task' in result['message']

    # Should be able to get status with real todo information
    status = await service.get_status()
    assert status['status_code'] == 200
    assert status['task_name'] == '[work] Test Task'  # With tags prefix
    assert status['task_id'] == sample_todo.id


@pytest.mark.asyncio
async def test_pomodoro_service_saves_completed_pomodoro_to_database(
    todo_repo, sample_todo, stub_sound_player, stub_notification_service
):
    service = PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )

    # Start a very short pomodoro (0.01 minutes = 0.6 seconds)
    result = await service.start_pomodoro(todo_id=sample_todo.id, duration=0.01)
    assert result['status_code'] == 200

    # Wait for the pomodoro to complete
    import asyncio

    await asyncio.sleep(0.8)  # Wait a bit longer than the pomodoro duration

    # Check that a completed pomodoro was saved to the database
    pomodoros = todo_repo.load_pomodoros_created_after(sample_todo.created_at)
    assert len(pomodoros) == 1

    completed_pomodoro = pomodoros[0]
    assert completed_pomodoro.todo_id == sample_todo.id
    assert completed_pomodoro.duration == 0.01
    assert completed_pomodoro.end_time is not None  # Should be completed
