#! env python
import sys
from pathlib import Path

import pandas as pd
from google.cloud import bigquery as bq

pd.set_option('display.max_columns', 500)
pd.set_option('display.width', 1_000_000)
pd.set_option('display.max_rows', 500)

# Expect table to come from bqlist command
table_name = sys.stdin.read().strip()
project_id, dataset, table_name, *_ = table_name.split('.')

print(project_id, dataset, table_name)

client = bq.Client()

query = f"""
SELECT 
    table_name, 
    column_name,
    data_type, 
    * EXCEPT(table_name, column_name, data_type)
FROM `{project_id}.{dataset}.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = '{table_name}'
"""

df = client.query(query).to_dataframe()

with open(Path().home() / f'ay_data/schemata/{table_name}.txt', 'w') as f:
    f.write(repr(df))
