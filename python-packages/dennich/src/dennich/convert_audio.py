import argparse
import json
from pathlib import Path

import openai

DESTINATION_FOLDER = Path('/home/denis/Sync/convert-audio/')


def convert_audio():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        'file_name', type=str, help='The path to the audio file to be transcribed.'
    )
    args = parser.parse_args()

    file_name = Path(args.file_name)

    output_text_file = DESTINATION_FOLDER / f'{file_name.stem}.json'

    print('starting audio transcription...')
    with open(file_name, 'rb') as f:
        transcript = openai.Audio.transcribe('whisper-1', f)

    print(f'saving transcribed audio to: {output_text_file}')

    with open(output_text_file, 'w') as f:
        json.dump(transcript, f)

    print('-------------------')
    print(transcript['text'])


def clean_transcription(transcript: str):
    prompt = """
The following is the transcript of an audio file:

---
{transcript}
---

Your job is to break the word blob into sentences.

Make the text readable as if it was written not spoken. You should remove words
that denote oral language such as "gonna", "well, ..."

Try to keep the main words used by the speaker, but to improve clarity, you
might rearrange the order of the words.

You must strive to keep the original flow of ideas in the order they appear in
the transcription.

The primary goal of the transcription is for the speaker to read his own
thoughts and rearrange and edit them at a later point in time.

Every time there's a new idea or a break of the flow, create a new paragraph so
that the text is easily scannable by the author in the future.
    """
    response = openai.ChatCompletion.create(
        model='gpt-3.5-turbo',
        messages=[
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': 'Who won the world series in 2020?'},
            {
                'role': 'assistant',
                'content': 'The Los Angeles Dodgers won the World Series in 2020.',
            },
            {'role': 'user', 'content': 'Where was it played?'},
        ],
    )


def main():
    convert_audio()
