"""
System tray launcher for the AymurAI backend API.

This script starts the Uvicorn server, writes logs to the per-user data
directory, and exposes basic controls via a Windows notification-area icon.
"""

from __future__ import annotations

import contextlib
import os
import signal
import subprocess
import sys
import threading
import time
from functools import partial
from pathlib import Path
from typing import TextIO

import pystray
from PIL import Image
from pystray import Menu, MenuItem

SCRIPT_DIR = Path(__file__).resolve().parent
DATA_DIR = Path(
    os.environ.get("AYMURAI_DATA_DIR", Path.home() / "AppData" / "Local" / "AymurAI")
)
LOG_DIR = Path(os.environ.get("AYMURAI_LOG_DIR", DATA_DIR / "logs"))
LOG_FILE = Path(os.environ.get("AYMURAI_LOG_FILE", LOG_DIR / "backend.log"))
ICON_PATH = Path(
    os.environ.get(
        "AYMURAI_TRAY_ICON",
        SCRIPT_DIR / "resources" / "app" / "build" / "app" / "favicon.ico",
    )
)

DEFAULT_LANGUAGE = "es"
REGISTRY_PATH = r"Software\AymurAI\Installer"
REGISTRY_VALUE = "Language"

LANGUAGE_ALIASES = {
    "en": "en",
    "english": "en",
    "1033": "en",
    "es": "es",
    "spa": "es",
    "spanish": "es",
    "1034": "es",
    "3082": "es",
}

LANGUAGE_STRINGS = {
    "tray_title_template": {
        "en": "AymurAI Backend ({status})",
        "es": "Backend de AymurAI ({status})",
    },
    "status_starting": {"en": "Starting", "es": "Iniciando"},
    "status_running": {"en": "Running", "es": "En ejecución"},
    "status_stopped": {"en": "Stopped", "es": "Detenido"},
    "notify_title": {"en": "AymurAI Backend", "es": "Backend de AymurAI"},
    "notify_restarted": {
        "en": "AymurAI backend restarted",
        "es": "El backend de AymurAI se reinicio",
    },
    "notify_unexpected_stop": {
        "en": "AymurAI backend stopped. Use the tray icon to restart it.",
        "es": "El backend de AymurAI se detuvo. Usa el icono de la bandeja para reiniciarlo.",
    },
    "menu_open_log": {"en": "Open log", "es": "Abrir log"},
    "menu_open_logs_folder": {
        "en": "Open log folder",
        "es": "Abrir carpeta de logs",
    },
    "menu_restart_backend": {
        "en": "Start / Restart backend",
        "es": "Iniciar / reiniciar backend",
    },
    "menu_stop_backend": {"en": "Stop backend", "es": "Detener backend"},
    "menu_quit": {"en": "Quit", "es": "Salir"},
}

BACKEND_COMMAND = [
    sys.executable,
    "-m",
    "uvicorn",
    "--app-dir=api",
    "main:api",
    "--host=0.0.0.0",
    "--port=8899",
]

CREATE_NO_WINDOW = getattr(subprocess, "CREATE_NO_WINDOW", 0x08000000)
CREATE_NEW_PROCESS_GROUP = getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0x00000200)


def _normalise_language(value: str | int | None) -> str:
    """
    Map registry or environment values to supported language codes.

    Args:
        value (str | int | None): The raw language value from environment or registry.

    Returns:
        str: The normalized language code ('en' or 'es'), or default if unrecognized.
    """
    if value is None:
        return DEFAULT_LANGUAGE

    if isinstance(value, int):
        return LANGUAGE_ALIASES.get(str(value), DEFAULT_LANGUAGE)

    token = value.strip().lower()
    return LANGUAGE_ALIASES.get(token, DEFAULT_LANGUAGE)


def detect_language() -> str:
    """Determine the UI language based on environment or registry settings."""

    env_lang = os.environ.get("AYMURAI_LANG")
    if env_lang:
        return _normalise_language(env_lang)

    if os.name == "nt":
        try:
            import winreg  # type: ignore

            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, REGISTRY_PATH) as key:
                raw_value, _ = winreg.QueryValueEx(key, REGISTRY_VALUE)
        except FileNotFoundError:
            return DEFAULT_LANGUAGE
        except OSError:
            return DEFAULT_LANGUAGE
        else:
            return _normalise_language(raw_value)

    return DEFAULT_LANGUAGE


class Localizer:
    """Provide language-specific strings with graceful fallback."""

    def __init__(self, language: str) -> None:
        self.language = language if language in {"en", "es"} else DEFAULT_LANGUAGE

    def get(self, key: str, **kwargs: object) -> str:
        """
        Retrieve a localized string by key, formatting with kwargs if provided.

        Args:
            key (str): The key identifying the string to retrieve.
            **kwargs (object): Optional keyword arguments for string formatting.

        Returns:
            str: The localized and formatted string.
        """
        options = LANGUAGE_STRINGS.get(key, {})
        text = (
            options.get(self.language)
            or options.get(DEFAULT_LANGUAGE)
            or options.get("en")
            or key
        )
        if kwargs:
            with contextlib.suppress(Exception):
                return text.format(**kwargs)
        return text


class TrayApp:
    """Manage the backend process and accompanying system tray icon."""

    def __init__(self, localizer: Localizer) -> None:
        """Initialize the TrayApp, setting up process management, logging, and tray icon image."""
        self.localize = localizer
        self.process: subprocess.Popen[str] | None = None
        self.log_handle: TextIO | None = None
        self.lock = threading.Lock()
        self.stop_event = threading.Event()
        self.icon: pystray.Icon | None = None
        self.image = self._load_icon_image()
        self.monitor_thread = threading.Thread(
            target=self._monitor_backend, daemon=True
        )

    def _load_icon_image(self) -> Image.Image:
        """Load the best available icon for the tray from the specified or default path."""
        candidate = (
            ICON_PATH
            if ICON_PATH.exists()
            else SCRIPT_DIR
            / "resources"
            / "app"
            / "build"
            / "app"
            / "favicon.ico"
        )
        with Image.open(candidate) as source:
            return source.copy()

    def _ensure_log_dir(self) -> None:
        """Ensure the log directory exists."""
        LOG_DIR.mkdir(parents=True, exist_ok=True)

    def _open_log(self) -> None:
        """Open the log file for appending log messages."""
        self._ensure_log_dir()
        self.log_handle = LOG_FILE.open("a", encoding="utf-8", buffering=1)

    def _close_log(self) -> None:
        """Close the log file handle if open."""
        if self.log_handle is not None:
            with contextlib.suppress(Exception):
                self.log_handle.flush()
                self.log_handle.close()
        self.log_handle = None

    def _write_log(self, message: str) -> None:
        """
        Write a timestamped message to the log file.

        Args:
            message (str): The message to log.
        """
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        line = f"[{timestamp}] {message}\n"
        if self.log_handle is not None:
            with contextlib.suppress(Exception):
                self.log_handle.write(line)
                return

        self._ensure_log_dir()
        with contextlib.suppress(Exception):
            with LOG_FILE.open("a", encoding="utf-8") as handle:
                handle.write(line)

    def start_backend(self) -> None:
        """Start the backend Uvicorn server as a subprocess and begin monitoring."""
        with self.lock:
            if self.process is not None and self.process.poll() is None:
                return

            self._open_log()
            self._write_log("Starting Uvicorn backend")

            creationflags = 0
            if os.name == "nt":
                creationflags = CREATE_NO_WINDOW | CREATE_NEW_PROCESS_GROUP
            self.process = subprocess.Popen(
                BACKEND_COMMAND,
                cwd=str(SCRIPT_DIR),
                stdout=self.log_handle,
                stderr=subprocess.STDOUT,
                creationflags=creationflags,
            )

            if not self.monitor_thread.is_alive():
                self.monitor_thread.start()

        self._update_icon_title("running")

    def stop_backend(self, reason: str = "Stopped by user") -> None:
        """
        Stop the backend process gracefully and update status/logs.

        Args:
            reason (str): The reason for stopping the backend, for logging purposes.
                Default is "Stopped by user".
        """
        with self.lock:
            proc = self.process
            if proc is None:
                return

            if proc.poll() is None:
                _graceful_stop(proc)

            exit_code = proc.poll()
            self._write_log(f"Backend stopped ({reason}, code={exit_code})")
            self.process = None
            self._close_log()

        self._update_icon_title("stopped")

    def restart_backend(self) -> None:
        """Restart the backend process and notify the user."""
        self.stop_backend("Restart requested")
        time.sleep(0.5)
        self.start_backend()
        self._notify(self.localize.get("notify_restarted"))

    def open_log_file(self) -> None:
        """Open the backend log file in the system's file explorer."""
        self._ensure_log_dir()
        LOG_FILE.touch(exist_ok=True)
        _open_in_explorer(LOG_FILE)

    def open_logs_folder(self) -> None:
        """Open the logs folder in the system's file explorer."""
        self._ensure_log_dir()
        _open_in_explorer(LOG_DIR)

    def exit_application(self) -> None:
        """Signal the application to exit and stop the backend."""
        self.stop_event.set()
        self.stop_backend("Tray icon closed")

    def _monitor_backend(self) -> None:
        """Monitor the backend process and handle unexpected exits."""
        while not self.stop_event.is_set():
            time.sleep(2)

            with self.lock:
                proc = self.process

            if proc is None:
                continue

            exit_code = proc.poll()
            if exit_code is None:
                continue

            self._write_log(f"Backend exited unexpectedly (code={exit_code})")
            with self.lock:
                self.process = None
                self._close_log()

            self._update_icon_title("stopped")
            self._notify(self.localize.get("notify_unexpected_stop"))

    def _update_icon_title(self, status_key: str) -> None:
        """
        Update the tray icon's title to reflect backend status.

        Args:
            status_key (str): The status key to localize.
        """
        if self.icon is not None:
            title = self._format_title(status_key)
            self.icon.title = title

    def _format_title(self, status_key: str) -> str:
        """
        Format the tray icon title based on the current status.

        Args:
            status_key (str): The status key to localize.

        Returns:
            str: The formatted title string.
        """
        status_text = self.localize.get(f"status_{status_key}")
        template = self.localize.get("tray_title_template")
        return template.format(status=status_text)

    def _notify(self, message: str) -> None:
        """
        Show a notification message via the tray icon.

        Args:
            message (str): The message to display in the notification.
        """
        if self.icon is not None:
            with contextlib.suppress(Exception):
                self.icon.notify(message, self.localize.get("notify_title"))


def _open_in_explorer(path: Path) -> None:
    """
    Open the given file or directory in the system's file explorer.

    Args:
        path (Path): The file or directory to open.
    """
    try:
        if sys.platform.startswith("win"):
            os.startfile(str(path))  # type: ignore[attr-defined]
        elif sys.platform == "darwin":
            subprocess.Popen(["open", str(path)])
        else:
            subprocess.Popen(["xdg-open", str(path)])
    except Exception:
        pass


def _wait_for_process(proc: subprocess.Popen[str], timeout: float) -> bool:
    """
    Wait for a process to exit within a timeout.

    Args:
        proc (subprocess.Popen[str]): The process to wait for.
        timeout (float): The maximum time to wait in seconds.

    Returns:
        bool: True if the process exited, False if timeout expired.
    """
    try:
        proc.wait(timeout=timeout)
        return True
    except subprocess.TimeoutExpired:
        return False


def _graceful_stop(proc: subprocess.Popen[str]) -> None:
    """
    Attempt to gracefully stop a process, escalating to force if needed.

    Args:
        proc (subprocess.Popen[str]): The process to stop.
    """
    if proc.poll() is not None:
        _wait_for_process(proc, 5)
        return

    if os.name == "nt":
        proc.terminate()
        if not _wait_for_process(proc, 5):
            subprocess.run(
                ["taskkill", "/F", "/T", "/PID", str(proc.pid)],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False,
            )
            _wait_for_process(proc, 5)
        return

    proc.terminate()
    if not _wait_for_process(proc, 10):
        proc.kill()
        _wait_for_process(proc, 5)


def handle_signal(
    signum: int, _frame: object, app: TrayApp, icon: pystray.Icon
) -> None:
    """
    Handle received signal by exiting application and stopping icon.

    Args:
        signum (int): The signal number received.
        _frame (object): The current stack frame (unused).
        app (TrayApp): The tray application instance to shut down.
        icon (pystray.Icon): The tray icon to stop.
    """
    del signum
    app.exit_application()
    icon.stop()


def _setup_signal_handlers(app: TrayApp, icon: pystray.Icon) -> None:
    """
    Set up signal handlers for graceful shutdown on SIGINT/SIGTERM.

    Args:
        app (TrayApp): The tray application instance to shut down.
        icon (pystray.Icon): The tray icon to stop.
    """
    handler = partial(handle_signal, app=app, icon=icon)
    for sig in (signal.SIGINT, signal.SIGTERM):
        with contextlib.suppress(Exception):
            signal.signal(sig, handler)


def main() -> None:
    """Main entry point for the tray runner application."""
    language = detect_language()
    localizer = Localizer(language)
    app = TrayApp(localizer)

    menu = Menu(
        MenuItem(
            localizer.get("menu_open_log"),
            lambda _icon, _item: app.open_log_file(),
        ),
        MenuItem(
            localizer.get("menu_open_logs_folder"),
            lambda _icon, _item: app.open_logs_folder(),
        ),
        MenuItem(
            localizer.get("menu_restart_backend"),
            lambda _icon, _item: app.restart_backend(),
        ),
        MenuItem(
            localizer.get("menu_stop_backend"),
            lambda _icon, _item: app.stop_backend(),
        ),
        Menu.SEPARATOR,
        MenuItem(localizer.get("menu_quit"), lambda icon, _item: _quit(icon, app)),
    )

    initial_title = app._format_title("starting")
    icon = pystray.Icon("aymurai-backend", app.image, initial_title, menu)
    app.icon = icon
    _setup_signal_handlers(app, icon)

    app.start_backend()

    try:
        icon.run()
    finally:
        app.exit_application()


def _quit(icon: pystray.Icon, app: TrayApp) -> None:
    """Quit handler for the tray menu: exit app and stop icon."""
    app.exit_application()
    icon.stop()


if __name__ == "__main__":
    main()
