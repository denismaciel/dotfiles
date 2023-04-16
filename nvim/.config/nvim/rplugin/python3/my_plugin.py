import urllib.request
from html.parser import HTMLParser

import pynvim


# Custom parser to extract the text of the H1 tag
class H1Parser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_h1 = False
        self.h1_text = ''

    def handle_starttag(self, tag, attrs):
        if tag == 'h1':
            self.in_h1 = True

    def handle_endtag(self, tag):
        if tag == 'h1':
            self.in_h1 = False

    def handle_data(self, data):
        if self.in_h1 and self.h1_text == '':
            self.h1_text = data.strip()


# Function to fetch the HTML content of a URL
def get_html(url):
    req = urllib.request.Request(
        url,
        headers={
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
        },
    )
    with urllib.request.urlopen(req) as response:
        html = response.read().decode('utf-8')
    return html


# Function to extract the text of the H1 tag from HTML content
def get_h1_text(html):
    parser = H1Parser()
    parser.feed(html)
    return parser.h1_text


def get_page_title(url):
    html = get_html(url)
    h1_text = get_h1_text(html)
    return h1_text


@pynvim.plugin
class DenisPlugin(object):
    def __init__(self, nvim):
        self.nvim = nvim

    @pynvim.command('ReadBlog', nargs='*', sync=True)
    def add_text_below(self, args):
        url = ' '.join(args)
        url = url.strip()
        title = get_page_title(url)

        out = f'### [{title}]({url})'

        current_line = self.nvim.current.window.cursor[0]
        self.nvim.current.buffer.append(out, current_line)
