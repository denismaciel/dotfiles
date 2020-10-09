import json
import sys
from datetime import date
from datetime import timedelta
from pathlib import Path
from typing import Tuple
from typing import Union

from google.cloud import bigquery

from aymario.auth import Config


def load_config(path):
    with open(path) as f:
        return json.load(f)


def check_syntax(query: str) -> Union[str, Exception]:
    # dry_run makes sure no data is processed
    job_config = bigquery.QueryJobConfig(dry_run=True, use_query_cache=False)
    client = bigquery.Client(project="bi-s-pricing")

    try:
        _ = client.query(query, job_config=job_config)
    except Exception as e:
        return e
    else:
        return "~~~ Yay! Query compiles ~~~"


def main():
    import os
    from datetime import datetime

    config_dict = load_config("config/compiled/dev_local/base.json")

    run_date = date.today() - timedelta(days=1)
    runtime_vars = {
        "RUN_DATE": run_date,
        "FORECAST_DATE": run_date,
        "FORECAST_DATE_TABLE_ID": format(run_date, "%Y%m%d"),
        "COUNTRY_CLUSTER": "DE",
        "COUNTRY_CODE": "DE",
        "APPLICATION_ID": [135],
    }

    c = Config()
    c.from_dict(config_dict["self_conf"])
    c.from_dict(runtime_vars)

    config_file = sys.argv[1]

    with open(config_file, "r") as f:
        sql = f.read().format(**c())

    print(check_syntax(sql))


if __name__ == "__main__":
    exit(main())
