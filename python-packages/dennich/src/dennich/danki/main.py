from __future__ import annotations

import json
import re
import sqlite3
import warnings
from pathlib import Path
from typing import Any
from typing import NamedTuple

from markdownify import markdownify

ANKI_DATABASE_FILE = '/home/denis/.local/share/Anki2/denis/collection.anki2'
ANKI_NOTES_DIR = Path('/home/denis/Sync/Notes/Current/Anki')
INDEX_FILE = ANKI_NOTES_DIR / 'index.json'
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

    def _file_name(self) -> str:
        return f'{self.note_id}-{slugify(self.title)}.md'

    def file_path(self) -> Path:
        return ANKI_NOTES_DIR / self._file_name()

    def to_dict(self) -> dict[str, Any]:
        return {
            'id': self.note_id,
            'title': self.title,
            'front': self.front,
            'back': self.back,
            'raw': self.raw,
            'file_path': str(self.file_path().absolute()),
        }


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
    # dump one file per note
    for note in notes:
        with open(note.file_path(), 'w') as f:
            f.write(format_as_markdown_file(note))

    # dump index file which is used by neovim
    with open(INDEX_FILE, 'w') as f:
        json.dump(
            {'notes': [note.to_dict() for note in notes]},
            f,
        )


def main() -> int:
    notes = load_notes()
    write_notes(notes)
    return 0


if __name__ == '__main__':
    exit(main())
