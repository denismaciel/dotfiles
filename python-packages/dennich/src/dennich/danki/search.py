from __future__ import annotations

import shutil
import sqlite3
from typing import NamedTuple

from markdownify import markdownify
from plumbum.commands.processes import ProcessExecutionError
from pyfzf.pyfzf import FzfPrompt

TERMINAL_WIDTH, _ = shutil.get_terminal_size()


def center_text(text: str, sep: str = '=') -> str:
    return f'   {text}   '.center(TERMINAL_WIDTH, sep)


def render(text: str) -> str:
    # text = text.replace("<br />", "\n")
    # text = text.replace("<br>", "\n")
    # text = text.replace("<div>", "\n")
    # text = text.replace("</div>", "")
    # text = text.replace("&nbsp;", " ")
    # text = text.strip()

    text = markdownify(text)
    text = text.replace(r'\_', '_')
    return text


class Note(NamedTuple):
    note_id: int
    title: str
    front: str
    back: str

    @classmethod
    def from_sql(cls, record: tuple[int, str]) -> Note:
        id, fields = record
        front, back, *_ = fields.split(chr(31))
        first_line = front.split('<br>')[0]
        return Note(note_id=id, title=first_line, front=front, back=back)


def main() -> int:
    fzf = FzfPrompt()
    con = sqlite3.connect('/home/denis/.local/share/Anki2/denis/collection.anki2')
    cursor = con.cursor()

    notes = [
        Note.from_sql(record) for record in cursor.execute('SELECT id, flds FROM notes')
    ]

    rendered_notes = {
        render(note.title): note for note in notes if '%cpaste' not in note.front
    }
    try:
        (chosen_title,) = fzf.prompt(f'{title}' for title in rendered_notes)
    except ProcessExecutionError:
        print('Aborting...')
        return 0

    note = notes[chosen_title]
    print(
        center_text(f'Front ({note.note_id})', sep='-'),
        render(note.front),
        center_text('Back', sep='-'),
        render(note.back),
        '-' * TERMINAL_WIDTH,
        sep='\n\n',
    )
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
