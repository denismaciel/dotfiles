import datetime as dt

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session
from sqlalchemy.orm import sessionmaker

from dennich.todo.models import Base
from dennich.todo.models import Pomodoro
from dennich.todo.models import Todo
from dennich.todo.models import TodoType


@pytest.fixture(scope='function')
def session():
    # Create an in-memory SQLite database for testing
    engine = create_engine('sqlite:///:memory:')

    # Create all tables in the database
    Base.metadata.create_all(engine)

    # Create a scoped session factory
    session_factory = sessionmaker(bind=engine)
    Session = scoped_session(session_factory)

    # Create a new session
    session = Session()

    yield session  # This is where the testing happens

    # Teardown - rollback any changes made during the tests
    session.rollback()
    session.close()
    Session.remove()
    Base.metadata.drop_all(engine)


def test_todo_operations(session):
    # Add a new Todo
    new_todo = Todo(
        name='Complete Python Project',
        type=TodoType.TODO,
    )
    session.add(new_todo)
    session.commit()

    # Query this new Todo
    added_todo = session.query(Todo).filter_by(name='Complete Python Project').first()
    assert added_todo is not None
    print(f'Added Todo: {added_todo.name}')

    # Update the Todo
    added_todo.name = 'Complete Python Course'
    session.commit()

    # Query and assert the update
    updated_todo = session.query(Todo).filter_by(name='Complete Python Course').first()
    assert updated_todo is not None
    print(f'Updated Todo: {updated_todo.name}')

    # Delete the Todo
    session.delete(added_todo)
    session.commit()

    # Assert the Todo is deleted
    deleted_todo = session.query(Todo).filter_by(name='Complete Python Course').first()
    assert deleted_todo is None
    print('Todo deleted successfully')


def test_todo_with_multiple_pomodoros(session):
    # Create a new Todo
    new_todo = Todo(name='Complete Python Project')
    session.add(new_todo)
    session.commit()

    # Create multiple Pomodoros
    pomodoro_one = Pomodoro(
        todo_id=new_todo.id,
        start_time=dt.datetime.now(),
        duration=25,
    )
    pomodoro_two = Pomodoro(
        todo_id=new_todo.id,
        start_time=dt.datetime.now() + dt.timedelta(hours=1),
        duration=25,
    )

    # Add Pomodoros to the session
    session.add(pomodoro_one)
    session.add(pomodoro_two)
    session.commit()

    # Retrieve the Todo and its Pomodoros
    todo_with_pomodoros = session.query(Todo).filter_by(id=new_todo.id).one()
    pomodoros = session.query(Pomodoro).filter_by(todo_id=new_todo.id).all()

    # Assertions
    assert todo_with_pomodoros is not None
    assert len(pomodoros) == 2
    assert pomodoros[0].todo_id == new_todo.id
    assert pomodoros[1].todo_id == new_todo.id

    print(f'Todo: {todo_with_pomodoros.name}')
    for pomo in pomodoros:
        print(f'Pomodoro start time: {pomo.start_time}')
