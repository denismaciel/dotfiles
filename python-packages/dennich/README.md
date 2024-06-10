# CLI tools just for me

## Commands

Get full systemd logs.

```sh
journalctl --user -u pomodoro-server.service
```

Get status of systemd service.

```sh
systemctl --user status pomodoro-server
```

Restart systemd service.

```sh
systemctl --user restart pomodoro-server
```

Clean systemd logs.

```sh
# keep only logs since yesterday.
sudo journalctl --user --vacuum-time=1days
```

Install new version of code.

```sh
pipx install --force -e ~/dotfiles/python-packages/dennich
```




## Todos

- [ ] Handle gracefully shutting down the server so that the port doesn't stay busy for 20s or so after the shutdown.
