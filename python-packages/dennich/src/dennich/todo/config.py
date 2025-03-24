from dataclasses import dataclass


@dataclass
class Config:
    port: int
    database_url: str


def load_config() -> Config:
    return Config(port=12347, database_url='/home/denis/Sync/todo.db')
