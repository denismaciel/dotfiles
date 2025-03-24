from __future__ import annotations

import datetime as dt
import enum
import re
from collections.abc import Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Literal
from typing import TypedDict

from sqlalchemy import JSON
from sqlalchemy import DateTime
from sqlalchemy import Enum
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import String
from sqlalchemy import create_engine
from sqlalchemy import select
from sqlalchemy.orm import DeclarativeBase
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import Session
from sqlalchemy.orm import mapped_column
from sqlalchemy.orm import relationship
from sqlalchemy.orm import sessionmaker

from dennich.todo.config import load_config


class ReqStartPomdoro(TypedDict):
    action: Literal['start']
    todo_id: int
    duration: float


class ReqCancelPomdoro(TypedDict):
    action: Literal['cancel']


class ReqStatusPomdoro(TypedDict):
    action: Literal['status']


Request = ReqStartPomdoro | ReqCancelPomdoro | ReqStatusPomdoro


class Base(DeclarativeBase): ...


RE_TAG = re.compile(r'#[\w,-]+')


class TodoType(enum.StrEnum):
    TODO = 'todo'
    HABIT = 'habit'


TodoAction = Literal['add', 'complete']


def find_tags(s: str) -> list[str]:
    return sorted([tag.replace('#', '') for tag in RE_TAG.findall(s)])


class Todo(Base):
    __tablename__ = 'todos'

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String)
    type: Mapped[TodoType] = mapped_column(Enum(TodoType), default=TodoType.TODO)
    created_at: Mapped[dt.datetime] = mapped_column(
        DateTime, default=dt.datetime.now, index=True
    )
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
        return f'{tags_str} \t {self.name}'


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


def sort_todos(todos: Sequence[Todo]) -> list[Todo]:
    """
    1. Last active.
    2. Sorted by tag.
    3. Within a tag, underscore last.
    """
    if len(todos) == 0:
        return []

    def custom_sort(todo: Todo) -> tuple[bool, str]:
        first = todo.tags[0] if todo.tags else 'zzz'
        second = todo.name.startswith('_')
        return second, first

    first = todos[0]
    others = sorted(todos[1:], key=custom_sort)

    return [first, *others]


@dataclass
class TodoRepo:
    session: Session

    def load_pomodoros_created_after(self, date: dt.datetime) -> list[Pomodoro]:
        stmt = (
            select(Pomodoro)
            .where(Pomodoro.start_time >= date)
            .order_by(Pomodoro.start_time.desc())
        )
        return list(self.session.scalars(stmt))

    def load_todo_by_id(self, todo_id: int) -> Todo:
        stmt = select(Todo).where(Todo.id == todo_id)
        return self.session.scalars(stmt).one()

    def load_todos(self) -> Sequence[Todo]:
        stmt = select(Todo).where(Todo.completed_at == None).order_by(Todo.order.desc())  # noqa: E711
        return self.session.scalars(stmt).all()

    def create_pomodoro(self, pomodoro: Pomodoro) -> Pomodoro:
        self.session.add(pomodoro)
        self.session.commit()
        self.session.refresh(pomodoro)
        return pomodoro

    def upsert_todo(self, todo: Todo) -> None:
        self.session.add(todo)
        self.session.commit()


def get_db_url() -> str:
    config = load_config()
    file = Path(config.database_url).resolve()
    db_url = f'sqlite:///{file}'
    return db_url


def get_session() -> Session:
    engine = create_engine(get_db_url())
    Session = sessionmaker(bind=engine)
    Base.metadata.create_all(engine)
    session = Session()
    return session


class GetStatusResponse(TypedDict):
    status_code: Literal[200]
    remaining_time: float
    task_name: str
    task_id: int
    task_time_spent: float


class ErrorResponse(TypedDict):
    status_code: Literal[404]
    message: str


class Response(TypedDict):
    status_code: int
    message: str
