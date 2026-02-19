#!/usr/bin/env python3

import subprocess
import json
import re
bar="▁▂▃▄▅▆▇█"

def get_wifi_info():
    try:
        # Используем nmcli для получения информации
        result = subprocess.run(
            ['nmcli', '-t', '-f', 'ACTIVE,SSID,SIGNAL,RATE', 'dev', 'wifi'],
            capture_output=True,
            text=True
        )
        
        for line in result.stdout.strip().split('\n'):
            if line.startswith('да:'):
                _, ssid, signal, speed = line.split(':')
                signal_int = int(signal)
                bars = bar[:signal_int * (len(bar))//101 + 1]
                class_name = "warning"
                if signal_int > 50:
                    class_name = "good"
                
                # Форматируем скорость
                if 'Mbit' in speed:
                    speed_clean = speed.replace(' Mbit/s', 'M')
                else:
                    speed_clean = speed
                
                return {
                    "text": f"{bars} {ssid}",
                    "class": class_name,
                    "tooltip": f"Signal: {signal}%\nSpeed: {speed}"
                }
        
        return {"text": "No WiFi", "class": "critical"}
          
    except Exception as e:
        return {"text": "Error WiFi", "class": "critical"}

if __name__ == "__main__":
    info = get_wifi_info()
    print(json.dumps(info))