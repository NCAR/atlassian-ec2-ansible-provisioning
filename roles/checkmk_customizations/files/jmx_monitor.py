#!/usr/bin/python

import argparse
import yaml
from jmxquery import JMXConnection, JMXQuery
import pprint

jmx_port = 8099
config_file = "/usr/local/etc/jmx_monitor.yml"

parser = argparse.ArgumentParser()
parser.add_argument("-l", "--list", action="store_true", help="List all jmx objects")
args = parser.parse_args()

jmxConnection = JMXConnection("service:jmx:rmi:///jndi/rmi://localhost:" + str(jmx_port) + "/jmxrmi")

if args.list:
    jmxQuery = [JMXQuery("*:*")]
    objects = jmxConnection.query(jmxQuery)
    for object in objects:
        print(f"{object.to_query_string()} ({object.value_type}) = {object.value}")
    sys.exit()

    
with open(config_file, 'r') as file:
    config = yaml.safe_load(file)
for k, v in config.items():
    search_params = v.str.strip("{}")
    query = [
        JMXQuery(k + ":" + search_params)
    ]
    jmx_results = jmxConnection.query(query)
    for jr in jmx_results:
        pprint.pprint(jr)
