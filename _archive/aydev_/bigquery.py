"""
How to call this:

    python <cmd> [args,]
    python snapshot query_file.sql subquery_name
    python check_syntax query_file.sql
"""
import json
import os
import re
import sys
from datetime import date
from datetime import timedelta
from pathlib import Path
from typing import Union

import pandas as pd
import yaml
from aymario.auth import Config
from aymario.auth import get_bq_client
from aymario.devtools import mock_flowspec
from aymario.gbq_interact import format_query
from aymario.sql import extract_runnable_cte
from google.cloud import bigquery


def get_client():
    c = Config()
    c.GOOGLE_APPLICATION_CREDENTIALS = os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
    c.PROJECT_ID = 'bi-s-pricing'
    return get_bq_client(c)


def parse_header(query_string):
    bangs = [m.start() for m in re.finditer('###', query_string)]
    try:
        begin, end, *_ = bangs
    except ValueError:
        print('Could not parse a config header')
        vars = {}
    else:
        begin += 3
        vars = yaml.safe_load(query_string[begin:end])

    print('Variables from file header: ', vars)
    return vars


def load_config(path):
    with open(path) as f:
        return json.load(f)


def check_syntax(query: str) -> Union[str, Exception]:
    client = get_client()
    job_config = bigquery.QueryJobConfig(dry_run=True, use_query_cache=False)
    try:
        _ = client.query(query, job_config=job_config)
    except Exception as e:
        return e
    else:
        return '~~~ Yay! Query compiles ~~~'


def cmd_compile(file, args, configs, **kwargs):
    with open(file, 'r') as f:
        sql = format_query(f.read(), configs)
    print(sql)
    return 0


def cmd_check_compilation(file, args, configs, **kwargs):
    with open(file, 'r') as f:
        sql = format_query(f.read(), configs)
    print(check_syntax(sql))
    return 0


def cmd_snapshot(file, args, configs, **kwargs):
    pd.set_option('display.max_columns', 500)
    pd.set_option('display.width', 1_000_000)
    pd.set_option('display.max_rows', 1_000)

    cte = args[0]

    path_dir = file.parent

    with open(file, 'r') as f:
        query = format_query(f.read(), configs)

    runnable_cte = extract_runnable_cte(query, cte)
    client = get_client()
    res = client.query(runnable_cte)

    # Create directory if non existent
    snaps_dir = path_dir / 'snaps' / file.stem
    if not snaps_dir.exists():
        os.makedirs(snaps_dir)

    # Save to file
    suffix = ''
    for k, v in kwargs['file_vars'].items():
        suffix += f'__{k}_{v}'

    # Limit file name length
    suffix = suffix[:50]

    with open(snaps_dir / (cte + suffix + '.txt'), 'w') as f:
        f.write(repr(res.to_dataframe()))

    return 0


def cmd_whole_query(file, args, config, **kwargs):
    import time

    client = get_client()

    with open(file) as f:
        sql = format_query(f.read(), config)
        print(sql)
    job = client.query(sql)

    while job.running():
        time.sleep(1)

    return 0


def main():
    conf = mock_flowspec('config/compiled/dev_local/deepar_train_v8.json').conf
    run_date = date.today() - timedelta(days=1)
    conf._d.update(
        {
            'RUN_DATE': run_date,
            'FORECAST_DATE': run_date,
            'FORECAST_DATE_TABLE_ID': format(run_date, '%Y%m%d'),
            'COUNTRY_CLUSTER': 'DE',
            'COUNTRY_CODE': 'DE',
            'APPLICATION_ID': '(135)',
        }
    )

    # Parse command line arguments
    _, command, file, *args = sys.argv

    file = Path(file)

    if not file.exists():
        raise FileNotFoundError(f'{file} does not exists')

    if not file.is_file():
        raise FileNotFoundError(f'{file} is not a file')

    with open(file) as f:
        file_vars = parse_header(f.read())
    conf._d.update(file_vars)

    commands = {
        'snapshot': cmd_snapshot,
        'compile': cmd_compile,
        'check_compilation': cmd_check_compilation,
        'whole_query': cmd_whole_query,
    }

    try:
        return commands[command](file, args, conf, file_vars=file_vars)
    except KeyError:
        raise Exception(f"Command '{command}' not found")


if __name__ == '__main__':
    exit(main())
