from __future__ import annotations

import re
import sqlite3
import warnings
from pathlib import Path
from typing import NamedTuple

from markdownify import markdownify

ANKI_DATABASE_FILE = '/home/denis/.local/share/Anki2/denis/collection.anki2'
ANKI_NOTES_DIR = Path('/home/denis/Sync/Notes/Current/Anki')
SPLIT_CHAR = chr(31)

# MarkupResemblesLocatorWarning
warnings.filterwarnings(
    'ignore',
    message='MarkupResemblesLocatorWarning',
)


class Note(NamedTuple):
    note_id: int
    title: str
    front: str
    back: str
    raw: str

    @classmethod
    def from_sql(cls, record: tuple[int, str]) -> Note:
        id, fields = record
        assert isinstance(fields, str)
        front, back, *_ = fields.split(SPLIT_CHAR)
        front = markdownify(front).strip()
        back = markdownify(back).strip()
        first_line = front.split('<br>')[0]
        first_line = front.split('\n')[0]

        return Note(
            note_id=id,
            title=first_line,
            front=front,
            back=back,
            raw=fields,
        )

    def is_code_only(self) -> bool:
        return self.title.startswith('```')

    def file_name(self) -> str:
        return f'{self.note_id}-{slugify(self.title)}.md'


def slugify(text: str) -> str:
    text = re.sub(r'[^\w\s-]', '', text).strip().lower()
    text = text.replace(' ', '-')
    return text


def format_as_markdown_file(note: Note) -> str:
    return f"""---
id: {note.note_id}
---

{note.front}

{note.back}
"""


def load_notes() -> list[Note]:
    con = sqlite3.connect(ANKI_DATABASE_FILE)
    with con:
        cursor = con.cursor()
        notes = [
            Note.from_sql(record)
            for record in cursor.execute('SELECT id, flds FROM notes')
        ]
        notes = [note for note in notes if not note.is_code_only()]
    return notes


def write_notes(notes: list[Note]) -> None:
    ANKI_NOTES_DIR.mkdir(parents=True, exist_ok=True)
    for note in notes:
        with open(ANKI_NOTES_DIR / note.file_name(), 'w') as f:
            f.write(format_as_markdown_file(note))


def main() -> int:
    notes = load_notes()
    for note in notes:
        print(note.file_name())
    write_notes(notes)
    return 0
