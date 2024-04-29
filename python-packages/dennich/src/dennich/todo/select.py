import os
import tempfile
from dataclasses import dataclass
from shutil import which
from typing import Protocol


@dataclass
class SelectionCancelled:
    ...


@dataclass
class SelectionExistingItem:
    id: int


@dataclass
class SelectionNewItem:
    text: str


Selection = SelectionExistingItem | SelectionNewItem | SelectionCancelled


class Selector(Protocol):
    def select(
        self,
        items: list[str],
        prompt: str | None = None,
        multi_select: bool | None = False,
    ) -> Selection:
        ...


class FzfPrompt:
    def __init__(self, executable_path: str | None = None) -> None:
        if executable_path:
            self.executable_path = executable_path
        elif not which('fzf') and not executable_path:
            raise SystemError(
                'fzf executable not found. Please install fzf or pass the path to the executable to the constructor'
            )
        else:
            self.executable_path = 'fzf'

    def prompt(
        self,
        choices: list[str],
        fzf_options: str = '',
        delimiter: str = '\n',
    ) -> tuple[str, ...]:
        choices_str = delimiter.join(map(str, choices))

        with tempfile.NamedTemporaryFile(delete=False) as input_file:
            with tempfile.NamedTemporaryFile(delete=False) as output_file:
                input_file.write(choices_str.encode('utf-8'))
                input_file.flush()

        os.system(
            f"{self.executable_path} {fzf_options} < \"{input_file.name}\" > \"{output_file.name}\""
        )

        with open(output_file.name, encoding='utf-8') as f:
            selection = tuple(line.strip() for line in f if line)

        os.unlink(input_file.name)
        os.unlink(output_file.name)

        return selection


def define_select_kind_from_fzf(selection: tuple[str, ...]) -> Selection:
    if len(selection) == 0:
        return SelectionCancelled()

    #  the user input did not match any existing item
    #  so it must be that the user wants to create a new item
    if len(selection) == 1 and selection[0] != '':
        return SelectionNewItem(text=selection[0])

    if len(selection) == 2:
        user_input, todo = selection
        _ = user_input

        idx, *_ = todo.split(' ')
        # user input can be empty, which means that the user selected an existing item with the arrow keys
        # user input can be a string which means that the user selected with fuzzy search
        # the distinction is, however, irrelevant for the rest of the program
        return SelectionExistingItem(id=int(idx))

    raise ValueError('Unhandled selection case')


class Fzf:
    def select(
        self,
        items: list[str],
        prompt: str | None = None,
        multi_select: bool | None = False,
    ) -> Selection:
        if multi_select is True:
            raise NotImplementedError('multi-select is not implemented')

        options = [
            '--height 100%',
            '--reverse',
            '--print-query',
            '--with-nth 2..',
            f'--prompt="{prompt} > "',
        ]

        # add index to items

        items = [f'{i} {item}' for i, item in enumerate(items)]

        # use FzfPrompt
        fzf = FzfPrompt()
        selection = fzf.prompt(
            choices=items,
            fzf_options=' '.join(options),
        )

        print(selection)

        return define_select_kind_from_fzf(selection)
