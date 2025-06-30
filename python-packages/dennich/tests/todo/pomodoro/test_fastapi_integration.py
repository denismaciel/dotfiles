import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from dennich.todo.models import Base
from dennich.todo.models import Todo
from dennich.todo.models import TodoRepo
from dennich.todo.pomodoro.fastapi_server import app
from dennich.todo.pomodoro.fastapi_server import get_pomodoro_service
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
    from dennich.todo.pomodoro.notifications import StubSoundPlayer

    return StubSoundPlayer()


@pytest.fixture
def stub_notification_service():
    """Create a stub notification service for testing"""
    from dennich.todo.pomodoro.notifications import StubNotificationService

    return StubNotificationService()


@pytest.fixture
def pomodoro_service(todo_repo, stub_sound_player, stub_notification_service):
    """Create a PomodoroService with database and stub implementations"""
    return PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )


@pytest.fixture
def client_with_service(pomodoro_service):
    """Create a TestClient with service dependency override"""
    app.dependency_overrides[get_pomodoro_service] = lambda: pomodoro_service
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()


def test_start_endpoint_uses_real_service(client_with_service, sample_todo):
    """Test that POST /pomodoro/start uses the real service"""
    response = client_with_service.post(
        '/pomodoro/start', json={'todo_id': sample_todo.id, 'duration': 25.0}
    )

    assert response.status_code == 200
    data = response.json()
    assert data['status_code'] == 200
    assert 'Started pomodoro for todo' in data['message']
    assert 'Test Task' in data['message']


def test_status_endpoint_uses_real_service(client_with_service, sample_todo):
    """Test that GET /pomodoro/status uses the real service"""
    # First start a pomodoro
    client_with_service.post(
        '/pomodoro/start', json={'todo_id': sample_todo.id, 'duration': 25.0}
    )

    # Then get status
    response = client_with_service.get('/pomodoro/status')

    assert response.status_code == 200
    data = response.json()
    assert data['status_code'] == 200
    assert 'remaining_time' in data
    assert data['task_id'] == sample_todo.id
    assert '[work] Test Task' in data['task_name']


def test_cancel_endpoint_returns_success_when_no_pomodoro_running(client_with_service):
    """Test that DELETE /pomodoro/cancel works when no pomodoro is running"""
    response = client_with_service.delete('/pomodoro/cancel')

    assert response.status_code == 200
    data = response.json()
    assert data['status_code'] == 200
    assert 'No Pomodoro task is running to cancel' in data['message']


def test_status_when_no_pomodoro_running(client_with_service):
    """Test status endpoint when no pomodoro is running"""
    response = client_with_service.get('/pomodoro/status')

    assert response.status_code == 200
    data = response.json()
    assert data['status_code'] == 404
    assert 'No Pomodoro task is running' in data['message']
