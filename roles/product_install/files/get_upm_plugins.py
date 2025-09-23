#!/usr/bin/python3                                                                                                                                                             

import argparse
import json
import os
import requests
import sys

parser = argparse.ArgumentParser(
    epilog="Environment variable ATL_REST_TOKEN must be set"
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

if response.status_code != 200:
    print(f'Error: {response.status_code}')
    sys.exit(1)

user_plugins={}
for plugin in response.json()["plugins"]:
    if not ( plugin["enabled"] and plugin["userInstalled"] and plugin["usesLicensing"] ):
        continue
    key = plugin["key"]

    detail_baseurl = base_url + "/plugins/1.0/available/" + key + "-key"
    version_response = requests.get(
        detail_baseurl,
        headers=headers)
    if version_response.status_code != 200:
        print("Could not get version or license information for plugin " + key, file=sys.stderr)
        continue

    user_plugin = {
        "name":  plugin["name"],
        "version": plugin["version"],
        "raw_license": version_response.json()["licenseDetails"]["rawLicense"]
    }

    user_plugins[key] = user_plugin

print( json.dumps(user_plugins) )

