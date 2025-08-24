import asyncio

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

import dennich.todo.pomodoro.fastapi_server as server_module
from dennich.todo.models import Base
from dennich.todo.models import Todo
from dennich.todo.models import TodoRepo
from dennich.todo.pomodoro.fastapi_server import nagging_task
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


@pytest.fixture
def test_service(todo_repo, stub_sound_player, stub_notification_service):
    """Create a test service instance"""
    return PomodoroService(
        repo=todo_repo,
        sound_player=stub_sound_player,
        notification_service=stub_notification_service,
    )


@pytest.fixture(autouse=True)
def reset_global_service():
    """Reset the global service before each test"""
    server_module._global_service = None
    yield
    server_module._global_service = None


@pytest.mark.asyncio
async def test_nagging_shows_notification_when_no_pomodoro_running(
    test_service, stub_notification_service
):
    """Test that nagging shows notification when no pomodoro is running"""
    # Setup global service for the nagging task
    server_module._global_service = test_service

    # Mock the nagging task to run once and stop
    original_sleep = asyncio.sleep
    sleep_count = 0

    async def mock_sleep(seconds):
        nonlocal sleep_count
        sleep_count += 1
        if sleep_count == 1:
            # First sleep - let it pass (initial delay)
            await original_sleep(0.1)  # Short delay for test
        else:
            # Stop the loop after first nagging attempt
            raise asyncio.CancelledError()

    # Patch asyncio.sleep temporarily
    asyncio.sleep = mock_sleep

    try:
        # Start nagging task and let it run once
        with pytest.raises(asyncio.CancelledError):
            await nagging_task()

        # Verify notification was called
        assert stub_notification_service.show_nagging_notification_called
        assert stub_notification_service.nagging_call_count == 1

    finally:
        # Restore original sleep
        asyncio.sleep = original_sleep


@pytest.mark.asyncio
async def test_nagging_does_not_show_notification_when_pomodoro_running(
    test_service, sample_todo, stub_notification_service
):
    """Test that nagging does not show notification when pomodoro is running"""
    # Setup global service for the nagging task
    server_module._global_service = test_service

    # Start a pomodoro
    await test_service.start_pomodoro(sample_todo.id, 25.0)

    # Verify pomodoro is running
    assert test_service.has_running_pomodoro()

    # Mock the nagging task to run once and stop
    original_sleep = asyncio.sleep
    sleep_count = 0

    async def mock_sleep(seconds):
        nonlocal sleep_count
        sleep_count += 1
        if sleep_count == 1:
            # First sleep - let it pass (initial delay)
            await original_sleep(0.1)  # Short delay for test
        else:
            # Stop the loop after first nagging attempt
            raise asyncio.CancelledError()

    # Patch asyncio.sleep temporarily
    asyncio.sleep = mock_sleep

    try:
        # Start nagging task and let it run once
        with pytest.raises(asyncio.CancelledError):
            await nagging_task()

        # Verify notification was NOT called since pomodoro is running
        assert not stub_notification_service.show_nagging_notification_called
        assert stub_notification_service.nagging_call_count == 0

    finally:
        # Restore original sleep
        asyncio.sleep = original_sleep


@pytest.mark.asyncio
async def test_nagging_respects_max_zenity_windows_limit(
    test_service, stub_notification_service
):
    """Test that nagging respects the maximum zenity windows limit"""
    # Setup global service for the nagging task
    server_module._global_service = test_service

    # Set notification count to maximum
    stub_notification_service.set_open_notification_count(
        15
    )  # MAX_NUMBER_OF_ZENITY_WINDOWS

    # Mock the nagging task to run once and stop
    original_sleep = asyncio.sleep
    sleep_count = 0

    async def mock_sleep(seconds):
        nonlocal sleep_count
        sleep_count += 1
        if sleep_count == 1:
            # First sleep - let it pass (initial delay)
            await original_sleep(0.1)  # Short delay for test
        else:
            # Stop the loop after first nagging attempt
            raise asyncio.CancelledError()

    # Patch asyncio.sleep temporarily
    asyncio.sleep = mock_sleep

    try:
        # Start nagging task and let it run once
        with pytest.raises(asyncio.CancelledError):
            await nagging_task()

        # Verify notification was NOT called due to window limit
        assert not stub_notification_service.show_nagging_notification_called
        assert stub_notification_service.nagging_call_count == 0

    finally:
        # Restore original sleep
        asyncio.sleep = original_sleep


@pytest.mark.asyncio
async def test_nagging_continues_after_exception():
    """Test that nagging continues running even if there's an exception"""
    # This test verifies the exception handling in nagging_task
    # Since the nagging task catches all exceptions and continues,
    # we just need to verify it doesn't crash

    # Mock get_global_service to raise an exception
    original_get_global_service = server_module.get_global_service

    call_count = 0

    def mock_get_global_service():
        nonlocal call_count
        call_count += 1
        if call_count == 1:
            raise Exception('Test exception')
        else:
            # Stop the loop after handling the exception
            raise asyncio.CancelledError()

    server_module.get_global_service = mock_get_global_service

    # Mock sleep to make the test faster
    original_sleep = asyncio.sleep

    async def mock_sleep(seconds):
        await original_sleep(0.1)  # Short delay for test

    asyncio.sleep = mock_sleep

    try:
        # Nagging task should handle the exception and continue
        with pytest.raises(asyncio.CancelledError):
            await nagging_task()

        # Verify that get_global_service was called twice
        # (once with exception, once to trigger CancelledError)
        assert call_count == 2

    finally:
        # Restore original functions
        server_module.get_global_service = original_get_global_service
        asyncio.sleep = original_sleep
