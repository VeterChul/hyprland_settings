#!/usr/bin/env python3
import os
import json
import subprocess
import sys

def check_html(text):
    tegs = ["<html>", "<body>", "<div>", "<p>", "<a>", "<br>"]
    for i in range(1, 7):
        tegs.append(f"<h{i}>")
    for teg in tegs:
        if teg in text:
            return True
    return False

def clean_html(text):
    # ОЧЕНЬ ПРОСТОЙ пример очистки HTML.
    # Для реального использования лучше использовать html.unescape и, возможно, BeautifulSoup.
    import re
    # Удаляем теги <html>, </html>
    tegs = ["<html>", "<body>", "<div>", "<p>", "<a>", "<br>"]
    for i in range(1, 7):
        tegs.append(f"<h{i}>")
    for teg in tegs:
        text = re.sub(r'</?html>', '', text, flags=re.IGNORECASE)
        # Удаляем все остальные HTML-теги
        text = re.sub(r'<[^>]+>', '', text)
    return text

if __name__ == "__main__":

    path_log = "/home/veter/.local/share/mako/notifications.log"

    if len(sys.argv) > 1:
        notification_id_str = sys.argv[1]
    else:
        # fallback для ручного тестирования (если нужно)
        notification_id_str = os.environ.get('id')
    
    with open(path_log, "a") as f:
        f.write(f"=== Script called ===\n")
        f.write(f"ID: {notification_id_str}\n")
        f.write(f"PATH: {os.environ.get('PATH', 'NOT SET')}\n")
    if not notification_id_str:
        #print("Переменная окружения 'id' не найдена.", file=sys.stderr)
        sys.exit(1)
    
    try:
        notification_id = int(notification_id_str)
    except ValueError:
        #print(f"Неверный формат ID уведомления: {notification_id_str}", file=sys.stderr)
        sys.exit(1)
    
    result = subprocess.run(['/usr/bin/makoctl', 'list', '-j'], capture_output=True, text=True, check=True)
    notifications = json.loads(result.stdout)

    for notification in notifications:
        if notification["id"] == notification_id:
            break
    
    if check_html(notification["body"]):
        notification["body"] = clean_html(notification["body"])

        subprocess.run(['/usr/bin/makoctl', "dismiss", "-n", notification_id_str], capture_output=True, text=True, check=True)
        
        app_name = notification["app_name"]
        summary = notification["summary"]
        body = notification["body"]
        urgency = notification["urgency"]

        cmd = [
            "/usr/bin/notify-send",
            "-a", app_name,
            "-u", urgency,
            summary,
            body
        ]

        subprocess.run(cmd, check=False)
    
    with open(path_log, "a") as file:
        file.write(str(notification))
    
