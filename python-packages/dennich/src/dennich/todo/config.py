from dataclasses import dataclass


@dataclass
class Config:
    port: int
    database_url: str
    nagging_interval_seconds: int
    zenity_bin: str


def load_config() -> Config:
    return Config(
        port=12347,
        database_url='/home/denis/Sync/todo.db',
        nagging_interval_seconds=60,
        zenity_bin='/etc/profiles/per-user/denis/bin/zenity',
    )
