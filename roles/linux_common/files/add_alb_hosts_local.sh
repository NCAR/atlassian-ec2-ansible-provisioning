#!/bin/bash

# Add static entries to /etc/hosts for everything served by our ALB
# Gets around occasional AWS DNS flakiness


alb_endpoint=$(aws ssm get-parameter  --name /global/alb_endpoint | jq -r '.Parameter.Value')
alb_hosts=$(aws ssm get-parameter  --name /global/alb_hosts | jq -r '.Parameter.Value' | tr ',' ' ')

for ip in $(host $alb_endpoint | awk '{print $NF}' | sort); do
    hosts_line="$ip $alb_hosts"

    # We already have a line for this ip
    if grep -q "^$ip" /etc/hosts; then
	# Need to replace the line
	if ! grep -qF "${hosts_line}" /etc/hosts; then
	    perl -i -pe "s/^$ip\s.*/$hosts_line/" /etc/hosts
	fi
    else
	echo "${hosts_line}" >> /etc/hosts
    fi
done
