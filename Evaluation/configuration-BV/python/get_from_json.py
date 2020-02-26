import json
from sys import argv

content = argv[1]
index = argv[2]
json_string = content.replace("|", ",")
data = json.loads(json_string)
print data[index]
