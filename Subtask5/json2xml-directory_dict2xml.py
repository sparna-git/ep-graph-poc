#! /usr/bin/env python

# prerequisites :
# install json2xml :
# sudo apt install python3-venv python3-pip
# pip3 install json2xml

import sys
import json
#from json2xml import json2xml
#from json2xml.utils import readfromurl, readfromstring, readfromjson
from dict2xml import dict2xml

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


def readfromjson(filename: str) -> dict:
    """
    Reads a json string and emits json string
    """
    try:
        json_data = open(filename)
        data = json.load(json_data)
        json_data.close()
        return data
    except ValueError as exp:
        print(exp)        
    except IOError as exp:
        print(exp)        



data = readfromjson(sys.argv[1])
print (dict2xml(data, wrap="all", indent="  "))

#print(json2xml.Json2xml(data, wrapper="all", pretty=True, attr_type=False).to_xml())