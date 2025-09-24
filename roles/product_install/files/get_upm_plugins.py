#!/usr/bin/python3

# Get UPM json for all enabled user-installed plugins

import argparse
import json
import os
import requests
import sys

parser = argparse.ArgumentParser(
    description="Get UPM json for all enabled user-installed plugins via REST API.",
    epilog="Environment variable ATL_REST_TOKEN must be set!"
)
parser.add_argument("atlassian_server")
args = parser.parse_args()

if "ATL_REST_TOKEN" not in os.environ:
    print("Environment variable ATL_REST_TOKEN not set", file=sys.stderr)
    sys.exit(1)

base_url='https://' + args.atlassian_server + '/rest'

headers={
    "Content-Type": "application/json",
    "Authorization": "Bearer " + os.environ["ATL_REST_TOKEN"]
}

response = requests.get(base_url + "/plugins/1.0/", headers=headers)

status_first_digit = int(str(num)[0])
if status_first_digit == 4:
    raise Exception("Request to REST API failed with code " + str(response.status_code) + "; API token expired or user doesn't have permission?")
if status_first_digit == 5:
    raise Exception("Request to REST API failed with code " + str(response.status_code) + "; app not running or API not available?")
if response.status_code != 200:
    raise Exception("Request to REST API failed with code " + str(response.status_code))

user_plugins={}
for plugin in response.json()["plugins"]:
    if not ( plugin["enabled"] and plugin["userInstalled"] ):
        continue
    key = plugin["key"]

    detail_baseurl = base_url + "/plugins/1.0/available/" + key + "-key"
    version_response = requests.get(
        detail_baseurl,
        headers=headers)
    if version_response.status_code != 200:
        print("Could not get version for plugin " + key, file=sys.stderr)
        continue

    user_plugins[key] = plugin

print( json.dumps(user_plugins) )
