import pytest
from todo import determine_action
from todo import find_tags
from todo import move_to_top
from todo import parse_rofi
from todo import Todo
from todo import TodoType


def test_Todo_from_jsonline():
    todo = Todo.from_jsonl('{"name": "do something"}')
    assert todo.name == 'do something'

    todo = Todo.from_jsonl(
        '{"name": "do something", "status": "active", "tags": ["a", "b"]}'
    )
    assert todo.name == 'do something'
    assert todo.status == 'active'
    assert todo.tags == ['a', 'b']


def test_Todo_string_representation():
    todo = Todo(name='do something')
    assert str(todo) == 'TODO do something'

    todo = Todo(name='do habitually something', type=TodoType.HABIT)
    assert str(todo) == 'HABIT do habitually something'

    todo = Todo(
        name='do habitually something', type=TodoType.HABIT, tags=['atag', 'another']
    )
    assert str(todo) == 'HABIT do habitually something #atag #another'


def test_find_tags():
    assert find_tags('no tags in here') == []
    assert find_tags('#atag lorem ipsum #another-tag') == ['atag', 'another-tag']


def test_Todo_from_text_prompt():
    todo = Todo.from_text_prompt(
        'do something #tag-in-middle trailing    text #tag-in-end'
    )

    assert todo.name == 'do something trailing text'
    assert todo.type == TodoType.TODO
    assert todo.tags == ['tag-in-middle', 'tag-in-end']

    todo = Todo.from_text_prompt('      ')
    assert todo.is_empty


def test_determine_action():
    todo = Todo(name='')
    existing_todos = [Todo(name='e1'), Todo(name='e2')]

    action = determine_action(todo, existing_todos)
    assert action == 'add'

    action = determine_action(todo, [todo] + existing_todos)
    assert action == 'complete'


def test_parse_rofi():
    assert parse_rofi('-1|text') == (-1, 'text')


def test_created_at_changes():
    t1 = Todo(name='t1')
    t2 = Todo(name='t2')

    assert t1.created_at < t2.created_at


@pytest.mark.parametrize(
    ('todo', 'todos', 'expected'),
    (
        (
            Todo(name='a'),
            [Todo(name='b'), Todo(name='a'), Todo(name='c')],
            ['a', 'b', 'c'],
        ),
        (
            Todo(name='a'),
            [Todo(name='a'), Todo(name='b'), Todo(name='c')],
            ['a', 'b', 'c'],
        ),
        # (),
    ),
)
def test_move_to_top(todo, todos, expected):
    got = [t.name for t in move_to_top(todo, todos)]
    assert got == expected
