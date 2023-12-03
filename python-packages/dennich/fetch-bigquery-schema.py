from pathlib import Path

from google.cloud import bigquery
from google.oauth2 import service_account

DATA_FOLDER = Path.home() / '.cache' / 'recap' / 'bigquery-schema'
DATA_FOLDER.mkdir(exist_ok=True, parents=True)

SKIP_DATASETS = [
    'analytics_267606563',
    'analytics_287980657',
    'staging_backup_physical',
]

key_path = '/home/denis/credentials/recap-prod-dbt-manager.json'

# Authenticate and create a client
credentials = service_account.Credentials.from_service_account_file(key_path)
client = bigquery.Client(credentials=credentials, project=credentials.project_id)


def list_datasets():
    datasets = client.list_datasets()
    print('Datasets:')
    for dataset in datasets:
        if dataset.dataset_id in SKIP_DATASETS:
            continue
        yield dataset.dataset_id


def get_dataset_schema(dataset_name):
    # List all tables in the dataset
    dataset_ref = client.dataset(dataset_name)
    tables = client.list_tables(dataset_ref)

    # Process each table
    for table in tables:
        if '_airbyte_tmp_' in table.table_id:
            continue

        if '__dbt_tmp' in table.table_id:
            continue

        if '_airbyte_raw_' in table.table_id:
            continue

        table_ref = dataset_ref.table(table.table_id)
        table_obj = client.get_table(table_ref)

        # Create a file named after the dataset and table
        file_name = f'{dataset_name}.{table.table_id}'
        with open(DATA_FOLDER / file_name, 'w') as file:
            # Write schema details to the file
            schema = sorted(
                (schema_field for schema_field in table_obj.schema),
                key=lambda x: x.name,
            )

            for schema_field in schema:
                file.write(f'{schema_field.name} {schema_field.field_type}\n')

        print(
            f'Schema for {table.table_id} in dataset {dataset_name} written to {file_name}'
        )


if __name__ == '__main__':
    for dataset in list_datasets():
        get_dataset_schema(dataset)
