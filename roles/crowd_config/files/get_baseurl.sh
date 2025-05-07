# This is app-specific

mycnf=$(/usr/local/bin/create_mycnf.sh)
echo $(mysql --defaults-file=$mycnf --batch -Ne "select property_value from cwd_property where property_name = 'base.url';")
rm $mycnf
