import yaml

with open('newsletters.yml', 'r') as f:
    nl = yaml.load(f, Loader=yaml.FullLoader)


def fmt(email):
    return f'from:{email}'


current_newsletters = nl['newsletter']
filter_ = ' OR '.join(fmt(email) for email in current_newsletters)

print(filter_)
