#!/bin/bash

tag=$1
if test -z $tag; then
    cat <<USAGE
$0 tag

Parse the database binary log into SQL statements and upload to S3
under $ATL_S3_PATH/binlog_parsed/.
USAGE
    exit 1
fi

# #
# # Create the config file for s3m if it doesn't exist
# #
# s3m_config='/root/.config/s3m/config.yml'
# if ! test -e "${s3m_config}"; then
#     aws_creds=$(aws_env_credentials_from_instance_role.sh)
#     . "${aws_creds}"
#     rm "${aws_creds}"

#     cat <<S3MCONFIG > "${s3m_config}"
# ---
# hosts:
#   aws:
#     region: $AWS_REGION
#     access_key: $AWS_ACCESS_KEY
#     secret_key: $AWS_SECRET_ACCESS_KEY
#     compress: true
   
# S3MCONFIG
# fi

# Extract the relevant env vars from cloud-init.
set_vars=$(mktemp)
grep '^export ATL_' /var/lib/cloud/instance/user-data.txt > $set_vars
. $set_vars
rm $set_vars

# Retrieve the db admin credentials
secret_string=$(aws secretsmanager get-secret-value \
		    --secret-id "${ATL_RDS_MASTER_CREDENTIAL_SECRET_ARN}" \
		    --output json | jq -r '.SecretString')
dbuser=$(echo $secret_string | jq -r '.username')
dbpassword=$(echo $secret_string | jq -r '.password')

bucket=$(echo $ATL_S3_PATH | awk -F/ '{print $3}')
bucket_path="$(echo $ATL_S3_PATH | awk -F/ '{print $4}')/binlog_parsed/$(date --iso-8601=seconds)_${tag}.zst"
bucket_url="s3://${bucket}/${bucket_path}"
echo "Writing binlog to s3://${bucket}/${bucket_path}"


# Potential race; i.e. file could be closed before binlog2sql starts reading it
lastlog=$(mysql -h "${ATL_DB_HOST}" --user="${dbuser}" --password="${dbpassword}" \
		--batch -sre 'show binary logs;' \
	      | tail -1 | awk '{print $1}')

trap "kill -HUP $$" SIGINT
binlog2sql.py -u "${dbuser}" --stop-never \
	      -p "${dbpassword}" \
	      -h "${ATL_DB_HOST}" \
	      -d "${ATL_JDBC_DB_NAME}" \
	      --start-file $lastlog \
    | zstd |  aws s3 cp - $bucket_url

# trap "kill -HUP $$" SIGINT
# binlog2sql.py -u "${dbuser}" --stop-never \
# 	      -p "${dbpassword}" \
# 	      -h "${ATL_DB_HOST}" \
# 	      -d "${ATL_JDBC_DB_NAME}" \
# 	      --start-file $lastlog \
#     | s3m --pipe "aws/${bucket}/${bucket_path}"

