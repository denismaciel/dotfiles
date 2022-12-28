import pathlib

import yaml

def fmt(email):
    return f'from:{email}'

def main():
    root = pathlib.Path(__file__).parent
    with open(root/'newsletters.yml', 'r') as f:
        nl = yaml.safe_load(f)

    current_newsletters = nl['newsletter']
    filter_ = ' OR '.join(fmt(email) for email in current_newsletters)
    print(filter_)

if __name__ == '__main__':
    raise SystemExit(main())
