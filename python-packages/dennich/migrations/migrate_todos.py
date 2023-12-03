import datetime as dt
import json

from dennich.todo.models import get_session
from dennich.todo.models import Todo


# This function will read the JSONL file and return Todo instances
def migrate_jsonl_to_todos(jsonl_file_path):
    todos = []
    with open(jsonl_file_path) as file:
        for line in file:
            data = json.loads(line)
            if data.get('created_at') is None:
                print('Skipping todo:', data['name'])
                continue
            todo = Todo(
                name=data['name'],
                type=data['type'],
                created_at=dt.datetime.fromisoformat(data['created_at']),
                completed_at=None
                if data['completed_at'] is None
                else dt.datetime.fromisoformat(data['completed_at']),
                # tags=data["tags"], # Assuming the tags are managed elsewhere as in the original `from_text_prompt` method
            )
            todos.append(todo)
    return todos


# Assuming `jsonl_file_path` is the path to your JSONL file
files = [
    '/home/denis/Sync/Notes/Current/done.jsonlines',
    '/home/denis/Sync/Notes/Current/todo.jsonlines',
]


for file in files:
    session = get_session()
    todos = migrate_jsonl_to_todos(file)
    for todo in todos:
        session.add(todo)
    session.commit()
