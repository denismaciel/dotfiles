import sys
import os
from pathlib import Path

from google.cloud import bigquery
import pandas as pd
from dotenv import dotenv_values

from aymario import SQLFile

pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1_000_000)

configs = dotenv_values("config/dev.env")

SQLFILE_PATH = Path(sys.argv[1])
SUBQUERY_NAME = sys.argv[2]

path_dir = SQLFILE_PATH.parent
file_name = SQLFILE_PATH.name

if not SQLFILE_PATH.exists():
    raise Exception(f"{file_name} does not exists")

if not SQLFILE_PATH.is_file():
    raise Exception(f"{file_name} ios not a file")


# Check if subquery exists
with open(SQLFILE_PATH) as f:
    fmt_content = f.read().format(**configs)
    sqlfile = SQLFile(fmt_content)

if SUBQUERY_NAME not in sqlfile.subquery_names:
    raise Exception(f"{SUBQUERY_NAME} is not a subquery of {file_name}")

# Query BQ
client = bigquery.Client()
query = sqlfile.runnable_subquery(SUBQUERY_NAME)
res = client.query(query)

# Create directory if non existent
snaps_dir = path_dir / "snaps" / SQLFILE_PATH.stem
if not snaps_dir.exists():
    os.makedirs(snaps_dir)

# Save to file
with open(snaps_dir / (SUBQUERY_NAME + ".txt"), 'w') as f:
    f.write(repr(res.to_dataframe()))
    