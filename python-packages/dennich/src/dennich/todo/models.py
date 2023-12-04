from __future__ import annotations

import datetime as dt
import enum
import re
from pathlib import Path
from typing import Literal
from typing import TypedDict

from sqlalchemy import create_engine
from sqlalchemy import DateTime
from sqlalchemy import Enum
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import JSON
from sqlalchemy import String
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column
from sqlalchemy.orm import relationship
from sqlalchemy.orm import Session
from sqlalchemy.orm import sessionmaker


class ReqStartPomdoro(TypedDict):
    action: Literal['start']
    todo_id: int
    duration: float


class ReqCancelPomdoro(TypedDict):
    action: Literal['cancel']


class ReqStatusPomdoro(TypedDict):
    action: Literal['status']


Request = ReqStartPomdoro | ReqCancelPomdoro | ReqStatusPomdoro


class Base(DeclarativeBase):
    ...


RE_TAG = re.compile(r'#[\w,-]+')


class TodoType(enum.StrEnum):
    TODO = 'todo'
    HABIT = 'habit'


TodoAction = Literal['add', 'complete']


def find_tags(s: str) -> list[str]:
    return [tag.replace('#', '') for tag in RE_TAG.findall(s)]


class Todo(Base):
    __tablename__ = 'todos'

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String)
    type: Mapped[TodoType] = mapped_column(Enum(TodoType), default=TodoType.TODO)
    created_at: Mapped[dt.datetime] = mapped_column(DateTime, default=dt.datetime.now)
    completed_at: Mapped[dt.datetime] = mapped_column(DateTime, nullable=True)
    order: Mapped[dt.datetime] = mapped_column(DateTime, default=dt.datetime.now)
    updated_at: Mapped[dt.datetime] = mapped_column(
        DateTime, default=dt.datetime.now, onupdate=dt.datetime.now
    )
    tags: Mapped[list[str]] = mapped_column(JSON, nullable=True, default=[])
    pomodoros = relationship('Pomodoro', back_populates='todo')

    @classmethod
    def from_text_prompt(cls, prompt: str) -> Todo:
        # This method should be adjusted to work with the ORM
        # Assuming `find_tags` is defined elsewhere to extract tags from the prompt
        tags = find_tags(prompt)

        words = prompt.split()
        # filter tags from words and TODO
        description = ' '.join(
            w.strip() for w in words if not w.startswith('#') and w.upper() != 'TODO'
        )

        return cls(
            name=description,
            tags=tags,
            type=TodoType.TODO,
        )

    @property
    def is_empty(self) -> bool:
        return self.name.strip() == ''

    def __repr__(self) -> str:
        return f'<Todo: {self.name}>'

    def __str__(self) -> str:
        if not self.tags:
            return self.name

        tags_str = ' '.join(f'#{tag}' for tag in self.tags)
        return f'{self.name} {tags_str}'


class Pomodoro(Base):
    __tablename__ = 'pomodoros'

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    todo_id: Mapped[int] = mapped_column(
        Integer, ForeignKey('todos.id'), nullable=False
    )
    start_time: Mapped[dt.datetime] = mapped_column(DateTime, nullable=False)
    end_time: Mapped[dt.datetime] = mapped_column(DateTime, nullable=True)
    duration: Mapped[int] = mapped_column(Integer, nullable=False)
    todo = relationship('Todo', back_populates='pomodoros')


def load_todos(sess: Session) -> list[Todo]:
    # TODO: find out why the `where` clause is not working
    # return (
    #     sess.query(Todo)
    #     .where(Todo.completed_at is None)
    #     .order_by(Todo.order.desc())
    #     .all()
    # )
    todos = sess.query(Todo).order_by(Todo.order.desc()).all()
    todos = [todo for todo in todos if todo.completed_at is None]
    return todos


def load_pomodoros_created_after(sess: Session, date: dt.datetime) -> list[Pomodoro]:
    return (
        sess.query(Pomodoro)
        .where(Pomodoro.start_time >= date)
        .order_by(Pomodoro.start_time.desc())
        .all()
    )


def load_todo_by_id(sess: Session, todo_id: int) -> Todo:
    return sess.query(Todo).filter_by(id=todo_id).one()


def upsert_todo(sess: Session, todo: Todo) -> None:
    sess.add(todo)
    sess.commit()


def get_session() -> Session:
    file = Path('/home/denis/Sync/todo.db').resolve()
    engine_file = f'sqlite:///{file}'
    engine = create_engine(engine_file)
    Session = sessionmaker(bind=engine)
    Base.metadata.create_all(engine)
    session = Session()
    return session


class GetStatusResponse(TypedDict):
    status_code: Literal[200]
    remaining_time: float
    task_name: str
    task_id: int


class ErrorResponse(TypedDict):
    status_code: Literal[404]
    message: str


class Response(TypedDict):
    status_code: int
    message: str
