import yaml

with open("../newsletters.yml") as f:
    nw = yaml.safe_load(f.read())

for label, senders in nw.items():
    print(f"Label: {label}")
    collapsed = ' OR\n'.join(f'"{sender}"' for sender in senders)
    print("from:(", collapsed,")")
    print("\n")

