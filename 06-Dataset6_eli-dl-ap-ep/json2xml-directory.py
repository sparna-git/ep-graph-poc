#! /usr/bin/env python

# prerequisites :
# install json2xml :
# sudo apt install python3-venv python3-pip
# pip3 install json2xml

import sys
from json2xml import json2xml
from json2xml.utils import readfromurl, readfromstring, readfromjson

# get the xml from an URL that return json
# data = readfromurl("https://coderwall.com/vinitcool76.json")
# print(json2xml.Json2xml(data).to_xml())

# get the xml from a json string
# data = readfromstring(
#    '{"login":"mojombo","id":1,"avatar_url":"https://avatars0.githubusercontent.com/u/1?v=4"}'
#)
#print(json2xml.Json2xml(data).to_xml())

# get the data from an file
# data = readfromjson("examples/licht.json")
# print(json2xml.Json2xml(data).to_xml())



data = readfromjson(sys.argv[1])
print(json2xml.Json2xml(data, wrapper="all", pretty=True, attr_type=False).to_xml())