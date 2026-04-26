from json import loads

with open("/home/veter/.config/waybar/modules/weather/weather.txt", "r") as f:
    j = loads(f.read())

m = j["text"].split("|")
if m[0] == "*":
    m = m[1:3]
else:
    m = m[:2]

print(" ".join(m))
