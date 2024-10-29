from dennich.todo.models import find_tags
from dennich.todo.models import Todo


def test_find_tags():
    assert find_tags('no tags in here') == []
    assert find_tags('#atag lorem ipsum #another-tag') == sorted(
        ['atag', 'another-tag']
    )


def test_Todo_from_text_prompt():
    todo = Todo.from_text_prompt(
        'do something #tag-in-middle trailing    text #tag-in-end'
    )

    assert todo.name == 'do something trailing text'
    # assert todo.tags == ['tag-in-middle', 'tag-in-end']

    todo = Todo.from_text_prompt('      ')
    assert todo.is_empty
