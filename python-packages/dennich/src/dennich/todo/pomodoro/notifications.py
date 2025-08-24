import asyncio
import os
from typing import Protocol


class SoundPlayer(Protocol):
    """Protocol for playing completion sounds"""

    async def play_completion_sound(self) -> None:
        """Play the pomodoro completion sound"""
        ...


class NotificationService(Protocol):
    """Protocol for showing system notifications"""

    async def show_nagging_notification(self) -> None:
        """Show a nagging notification when no pomodoro is running"""
        ...

    def count_open_notifications(self) -> int:
        """Count how many notification windows are currently open"""
        ...


class StubSoundPlayer:
    """Stub implementation for testing"""

    def __init__(self) -> None:
        self.play_completion_sound_called = False

    async def play_completion_sound(self) -> None:
        self.play_completion_sound_called = True


class RealSoundPlayer:
    """Real implementation for playing sounds"""

    def __init__(
        self, sound_file_path: str = '/home/denis/dotfiles/scripts/assets/win95.ogg'
    ) -> None:
        self.sound_file_path = sound_file_path

    async def play_completion_sound(self) -> None:
        """Play the pomodoro completion sound using mpv"""
        try:
            # Use asyncio subprocess to avoid blocking
            process = await asyncio.create_subprocess_exec(
                '/etc/profiles/per-user/denis/bin/mpv',
                self.sound_file_path,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            stdout, stderr = await process.communicate()

            # Could log the result if needed
            # log.info('Pomodoro completion sound played',
            #          stdout=stdout.decode('utf-8'),
            #          stderr=stderr.decode('utf-8'))
        except Exception:
            # Fail silently if sound can't be played
            pass


class RealNotificationService:
    """Real implementation for zenity notifications"""

    def __init__(self, zenity_bin: str = '/usr/bin/zenity') -> None:
        self.zenity_bin = zenity_bin

    async def show_nagging_notification(self) -> None:
        """Show a nagging notification using zenity"""
        try:
            process = await asyncio.create_subprocess_exec(
                self.zenity_bin,
                '--error',
                '--text',
                'Track your time!',
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            await process.communicate()
        except Exception:
            # Fail silently if notification can't be shown
            pass

    def count_open_notifications(self) -> int:
        """Count how many zenity notification windows are currently open"""
        try:
            # Path to the /proc directory where process information is kept
            proc_dir = '/proc'
            # List all entries in the /proc directory (these are process IDs or other system files)
            dirs = [d for d in os.listdir(proc_dir) if d.isdigit()]
            zenity_count = 0
            for pid in dirs:
                try:
                    cmd_path = os.path.join(proc_dir, pid, 'cmdline')
                    with open(cmd_path) as f:
                        cmdline = f.read()
                        if 'zenity' in cmdline:
                            zenity_count += 1
                except (FileNotFoundError, ProcessLookupError):
                    # The process might have ended before we could read its cmdline
                    continue
            return zenity_count
        except Exception:
            return 0


class StubNotificationService:
    """Stub implementation for testing"""

    def __init__(self) -> None:
        self.show_nagging_notification_called = False
        self.nagging_call_count = 0
        self._open_notification_count = 0

    async def show_nagging_notification(self) -> None:
        self.show_nagging_notification_called = True
        self.nagging_call_count += 1

    def count_open_notifications(self) -> int:
        return self._open_notification_count

    def set_open_notification_count(self, count: int) -> None:
        """Helper for testing"""
        self._open_notification_count = count
