"""
How to call this:

    python <cmd> [args,]
    python snapshot query_file.sql subquery_name
    python check_syntax query_file.sql
"""
import os
import re
import sys
from pathlib import Path
import datetime
import yaml

from google.cloud import bigquery
import pandas as pd
from dotenv import dotenv_values

from aymario.sql import SQLFile

import json
import sys
from datetime import date
from datetime import timedelta
from pathlib import Path
from typing import Tuple
from typing import Union

from google.cloud import bigquery
from google.oauth2 import service_account

from aymario.auth import Config


def parse_header(query_string):
    try:
        begin, end = [m.start() for m in re.finditer("###", query_string)]
    except ValueError:
        print("Could not parse a config header")
        vars = {}
    else:
        begin += 3
        vars = yaml.safe_load(query_string[begin:end])

    print("Variables from file header: ", vars)
    return vars


def load_config(path):
    with open(path) as f:
        return json.load(f)


def check_syntax(query: str) -> Union[str, Exception]:
    scopes = (
        "https://www.googleapis.com/auth/bigquery",
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/drive",
    )
    credentials = service_account.Credentials.from_service_account_file(
        os.getenv("GOOGLE_APPLICATION_CREDENTIALS"), scopes=scopes
    )
    # dry_run makes sure no data is processed
    job_config = bigquery.QueryJobConfig(dry_run=True, use_query_cache=False)
    client = bigquery.Client(project="bi-s-pricing", credentials=credentials)
    try:
        _ = client.query(query, job_config=job_config)
    except Exception as e:
        return e
    else:
        return "~~~ Yay! Query compiles ~~~"


def cmd_check_compilation(file, args, configs, **kwargs):
    with open(file, "r") as f:
        sql = f.read().format(**configs)
    print(check_syntax(sql))
    return 0


def cmd_snapshot(file, args, configs, **kwargs):
    pd.set_option("display.max_columns", 500)
    pd.set_option("display.width", 1_000_000)
    pd.set_option("display.max_rows", 1_000)

    subquery_name = args[0]

    path_dir = file.parent
    file_name = file.name

    with open(file, 'r') as f:
        file_content = f.read()

    sqlfile = SQLFile(file_content.format(**configs))

    if subquery_name not in sqlfile.subquery_names:
        raise Exception(f"{subquery_name} is not a subquery of {file_name}")

    scopes = (
        "https://www.googleapis.com/auth/bigquery",
        "https://www.googleapis.com/auth/cloud-platform",
        "https://www.googleapis.com/auth/drive",
    )
    credentials = service_account.Credentials.from_service_account_file(
        os.getenv("GOOGLE_APPLICATION_CREDENTIALS"), scopes=scopes
    )
    # Query BQ
    client = bigquery.Client(project="bi-s-pricing", credentials=credentials)
    query = sqlfile.runnable_subquery(subquery_name)
    res = client.query(query)

    # Create directory if non existent
    snaps_dir = path_dir / "snaps" / file.stem
    if not snaps_dir.exists():
        os.makedirs(snaps_dir)

    # Save to file
    suffix = ""
    for k, v in kwargs['file_vars'].items():
        suffix += f"__{k}_{v}"

    with open(snaps_dir / (subquery_name + suffix + ".txt"), "w") as f:
        f.write(repr(res.to_dataframe()))

    return 0


def main():
    configs = load_config("config/compiled/dev_local/shop_model.json")["self_conf"]
    run_date = date.today() - timedelta(days=1)
    RUNTIME_VARS = {
        "RUN_DATE": run_date,
        "FORECAST_DATE": run_date,
        "FORECAST_DATE_TABLE_ID": format(run_date, "%Y%m%d"),
        "COUNTRY_CLUSTER": "DE",
        "COUNTRY_CODE": "DE",
        "APPLICATION_ID": "(135)",
    }
    configs.update(RUNTIME_VARS)

    # Parse command line arguments
    _, command, file, *args = sys.argv

    file = Path(file)

    if not file.exists():
        raise FileNotFoundError(f"{file} does not exists")

    if not file.is_file():
        raise FileNotFoundError(f"{file} is not a file")

    with open(file) as f:
        file_vars = parse_header(f.read())
    configs.update(file_vars)

    commands = {"snapshot": cmd_snapshot, "check_compilation": cmd_check_compilation}

    try:
        return commands[command](file, args, configs, file_vars=file_vars)
    except KeyError:
        raise Exception(f"Command '{command}' not found")


if __name__ == "__main__":
    exit(main())
