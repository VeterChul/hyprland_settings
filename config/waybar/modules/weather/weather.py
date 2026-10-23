#!/home/$USER/.config/waybar/myenv/bin python

from time import sleep
from  datetime import datetime
import requests    
from json import loads, dumps

def quick_translate( text ) :
    try:
        url = f"https://api.mymemory.translated.net/get"
        params = {
            'q': text,
            'langpair': 'en|ru'
        }
        
        response = requests.get(url, params=params, timeout=5)
        data = response.json()
        
        if response.status_code == 200:
            return data['responseData']['translatedText']
        else:
            return "Ошибка перевода"
    except:
        return "Сервис недоступен"


def weather(city, test_flag) -> str:
    #if int(time()) % 1200 < 120 or test_flag:
        
        url = f"https://wttr.in/{city}?format=j1"
        try:
            print(url)
            response = requests.get(url)
            data = response.json()
            print(data)
            
            temp = data["current_condition"][0]["temp_C"]
            feels_like = data["current_condition"][0]["FeelsLikeC"]
            description = quick_translate(data["current_condition"][0]["weatherDesc"][0]["value"])
            
            return {"error"      : False,
                    "temp"       : int(temp),
                    "feels_like" : int(feels_like),
                    "description": description}
        except Exception as e:
            return {"error"      : True,
                    "text"       : "Ошибка при определении погоды",
                    "texr_ettor" : e}
    #else:
    #        return {"error"      : True,
    #                "text"       : "Не время"}

def str_j(json):
    r = ""
    for i in str(json):
        if i != "'":
            r += i
        else:
            r += '"'
    r += "\n"
    return r

if __name__ == "__main__":
    while True:
        now = datetime.now()
        time_now = f"{now.year}-{now.month}-{now.day} {now.hour}:{now.minute}:{int(now.second)}"
        info = weather("Москва", False)
        print(info)
        if info["error"]:

            sleep_time = 60

            with open("/home/veter/.config/waybar/modules/weather/weather_log.txt", "r") as f:
                info = loads(f.read().split("\n")[-2])
            info["error"] = True
            info["new"] = False
            info["new_s"] = "*|"
            info["time"] = str(datetime.now())
        else:

            sleep_time = 3600

            info["new"] = True
            info["new_s"] = ""
            info["time"] = str(datetime.now())
            info["recording_time"] = str(time_now)
            
        j = {"text" : f"{info["new_s"]}Улица:{info["temp"]}C|Ощущается:{info["feels_like"]}C|{info["description"]}",
             "tooltip": f"Время зависи:{info["recording_time"]}",
             "class": "good"}
        with open("/home/veter/.config/waybar/modules/weather/weather.txt", 'w') as f:
            f.write(str_j(j))


        with open("/home/veter/.config/waybar/modules/weather/weather_log.txt", "r") as f:
            if len(f.read().split("\n")) > 100:
                r = "w"            
            else:
                r = "a"

        with open("/home/veter/.config/waybar/modules/weather/weather_log.txt", r) as f:
            
            
            f.writelines(dumps(info) + "\n")
        sleep(sleep_time)
