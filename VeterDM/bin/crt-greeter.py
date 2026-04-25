#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pwd
import os
from pathlib import Path
import glob
import json
import os
import sys
from datetime import datetime

import socket
import struct
import json
import os

def send_greetd_command(sock, cmd_dict):
    """Отправляет JSON-команду в сокет greetd, используя native byte order."""
    data = json.dumps(cmd_dict).encode('utf-8')
    # Используем 'I' для native byte order (ВСЕГДА 4 байта)
    sock.sendall(struct.pack('I', len(data)) + data)

def recv_greetd_response(sock):
    """Читает ответ от greetd, используя native byte order."""
    raw_len = sock.recv(4)
    if len(raw_len) < 4:
        return None
    # Используем 'I' для native byte order
    msg_len = struct.unpack('I', raw_len)[0]
    # Читаем ровно msg_len байт данных
    data = sock.recv(msg_len)
    if len(data) < msg_len:
        return None
    return json.loads(data.decode('utf-8'))

def authenticate_and_start_session(user, password, cmd_list):
    """Аутентификация через greetd и запуск сессии.
       Возвращает True при успехе (после чего вызывающий код должен завершиться)."""
    sock_path = os.environ.get('GREETD_SOCK')
    if not sock_path:
        print("Ошибка: переменная GREETD_SOCK не установлена", file=sys.stderr)
        return False

    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(sock_path)
    except Exception as e:
        print(f"Ошибка подключения к greetd: {e}", file=sys.stderr)
        return False

    # 1. Создаём сессию
    send_greetd_command(sock, {"type": "create_session", "username": user})
    response = recv_greetd_response(sock)
    if not response or response.get("type") == "error":
        print("Ошибка при создании сессии:", response.get("error", "неизвестная"), file=sys.stderr)
        sock.close()
        return False

    # 2. Цикл обработки сообщений аутентификации
    c = 0
    while c < 5:
        if response.get("type") == "auth_message":
            msg_type = response.get("auth_message_type")
            # Если это запрос пароля (скрытый ввод)
            if msg_type == "secret":
                c += 1
                send_greetd_command(sock, {"type": "post_auth_message_response", "response": password})
            # Если информационное сообщение или другой тип (можно просто подтвердить)
            else:
                # Для простоты отвечаем пустой строкой
                send_greetd_command(sock, {"type": "post_auth_message_response", "response": ""})
        elif response.get("type") == "success":
            # Аутентификация пройдена, выходим из цикла
            break
        elif response.get("type") == "error":
            print("Ошибка аутентификации:", response.get("error", "неизвестная"), file=sys.stderr)
            sock.close()
            return False
        else:
            print(f"Неожиданный ответ greetd: {response}", file=sys.stderr)
            sock.close()
            return False

        # Ждём следующий ответ
        response = recv_greetd_response(sock)
        if response is None:
            print("Соединение с greetd потеряно", file=sys.stderr)
            sock.close()
            return False
    if c == 5:
        return False
    # 3. Запускаем сессию
    if isinstance(cmd_list, str):
        cmd_list = cmd_list.split()
    send_greetd_command(sock, {"type": "start_session", "cmd": cmd_list, "env": []})
    sock.close()
    # Важно: после этого скрипт должен завершиться, greetd сам запустит сессию
    return True

def get_state_file_path():
    """
    Возвращает путь к файлу состояния, используя переменную окружения HOME.
    Если HOME не задана (не должно случиться), использует /var/lib/crt-greeter как fallback.
    """
    home = os.environ.get('HOME')
    if not home:
        # fallback для отладки (в реальной среде HOME всегда будет задан)
        home = '/var/lib/crt-greeter'
    state_dir = os.path.join(home, '.config')
    os.makedirs(state_dir, exist_ok=True)
    return os.path.join(state_dir, 'greetd-state.json')

def load_state():
    """
    Загружает состояние из JSON-файла.
    Возвращает словарь с ключами: 'last_user', 'last_de', 'last_de_cmd'
    Если файла нет или он повреждён, возвращает None.
    """
    state_file = get_state_file_path()
    if not os.path.exists(state_file):
        return None
    try:
        with open(state_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
        # Проверяем наличие всех необходимых ключей
        if 'last_user' in data and 'last_de' in data and 'last_de_cmd' in data and 'time' in data:
            return data
        else:
            return None
    except (json.JSONDecodeError, IOError):
        return None

def save_state(user, de_name, de_cmd):
    """
    Сохраняет состояние в JSON-файл.
    - user: имя пользователя (строка)
    - de_name: отображаемое имя окружения (например "Hyprland")
    - de_cmd: команда запуска окружения (например "Hyprland")
    """
    state_file = get_state_file_path()
    data = {
        'last_user': user,
        'last_de': de_name,
        'last_de_cmd': de_cmd,
        'time':datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    with open(state_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2)
    # Устанавливаем безопасные права: только владелец (600)
    os.chmod(state_file, 0o600)

def get_user_list():
    """
    Возвращает список имён пользователей, которые могут входить в систему.
    Критерии: UID >= 1000, shell не является /usr/sbin/nologin или /bin/false.
    """
    users = []
    for entry in pwd.getpwall():
        if entry.pw_uid >= 1000 and entry.pw_shell not in ['/usr/bin/nologin', '/bin/false']:
            users.append(entry.pw_name)
    return sorted(users)

def get_desktop_environments():
    """
    Возвращает список доступных окружений рабочего стола (Wayland и X11).
    Парсит .desktop файлы в /usr/share/wayland-sessions/ и /usr/share/xsessions/.
    Возвращает список словарей: [{"name": "Hyprland", "exec": "Hyprland", "file_path": "/usr/share/wayland-sessions/hyprland.desktop"}, ...]
    """
    sessions = []
    session_dirs = [
        Path("/usr/share/wayland-sessions"),
        Path("/usr/share/xsessions"),
    ]
    
    for session_dir in session_dirs:
        if not session_dir.exists():
            continue
        for desktop_file in session_dir.glob("*.desktop"):
            # Простой парсинг .desktop файла
            name = None
            exec_cmd = None
            with open(desktop_file, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line.startswith('Name='):
                        name = line[5:].strip()
                    elif line.startswith('Exec='):
                        exec_cmd = line[5:].strip()
                        # Удаляем возможные аргументы типа %u, %U, %F и т.д.
                        exec_cmd = exec_cmd.split()[0]  # берём только команду без аргументов
                    if name and exec_cmd:
                        break
            if name and exec_cmd:
                sessions.append({
                    "name": name,
                    "exec": exec_cmd,
                    "file_path": str(desktop_file)
                })
    # Сортируем по имени для удобства
    sessions.sort(key=lambda x: x["name"])
    return sessions

if __name__ == "__main__":
    print("GREETD_SOCK:", os.environ.get('GREETD_SOCK'), flush=True)
    if authenticate_and_start_session("veter", "26022011", ["Hyprland"]):
        print("Соединение работает")
    else:
        print("Соединение не установлено")
    import time
    time.sleep(60)  # чтобы терминал не закрылся сразу
    sys.exit(0)