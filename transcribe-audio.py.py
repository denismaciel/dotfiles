import argparse
import mimetypes
import urllib.parse
import urllib.request


def transcribe_audio(file_path, api_url, language='en', task='transcribe'):
    # Load audio file
    with open(file_path, 'rb') as file:
        audio_data = file.read()

    # Create boundary and encode data
    boundary = '----PythonMultipartBoundary'
    body = []
    # Add parameters
    params = {'language': language, 'task': task}
    for name, value in params.items():
        body.append('--' + boundary)
        body.append(f'Content-Disposition: form-data; name="{name}"')
        body.append('')
        body.append(value)

    # Add file
    mime_type, _ = mimetypes.guess_type(file_path)
    if mime_type is None:
        mime_type = 'application/octet-stream'
    file_name = file_path.split('/')[-1]
    body.append('--' + boundary)
    body.append(
        f'Content-Disposition: form-data; name="audio_file"; filename="{file_name}"'
    )
    body.append(f'Content-Type: {mime_type}')
    body.append('')
    body.append(audio_data)

    # Finalize the body
    body.append('--' + boundary + '--')
    body.append('')
    body_bytes = bytearray()
    for part in body:
        if isinstance(part, str):
            part = part.encode('utf-8')
        body_bytes.extend(part)
        body_bytes.extend(b'\r\n')

    # Send request
    request = urllib.request.Request(api_url + '/asr', method='POST')
    request.add_header('Content-Type', f'multipart/form-data; boundary={boundary}')
    request.data = body_bytes

    # Get response
    try:
        with urllib.request.urlopen(request) as response:
            response_data = response.read().decode('utf-8')
            return response_data
    except urllib.error.HTTPError as e:
        return str(e)


# Example usage
api_url = 'http://localhost:9000'
file_path = '/home/denis/Downloads/Approach - Tuesday at 09-54.m4a'
response = transcribe_audio(file_path, api_url)
print(response)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('file_path', help='path to audio file')

    args = parser.parse_args()

    response = transcribe_audio(args.file_path, api_url)

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
