#! env python
import itertools
from pathlib import Path

from google.cloud import bigquery as bq

client_pricing_staging = bq.Client()
client_bi_production = bq.Client("bi-production-2")

datasets = itertools.chain(
    client_pricing_staging.list_datasets(), [client_bi_production.get_dataset("cube")]
)

table_names = []
for ds in datasets:
    ds_table_names = [
        tbl.full_table_id for tbl in client_pricing_staging.list_tables(ds.reference)
    ]
    table_names.extend(ds_table_names)


p = Path(__file__).parent

with open(p / "bq_tables_list.txt", "w") as f:
    content = "\n".join(table_names)
    f.write(content)

