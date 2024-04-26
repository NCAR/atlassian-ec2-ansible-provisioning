# Atlassian Data Center Installation Automation

This repository is a suite of Ansible roles, playbooks and support scripts to
automate the installation and maintenance of Atlassian Data Center products in
cloud environments.

On this page:

[TOC]

# Usage

## Configuring Data Center nodes on cloud deployments

The usual scenario for usage as part of a cloud deployment is to invoke the
script as part of post-creation actions invoked while a new product node is
being brought up. In the case of AWS, this would usually be done by
[cfn-init][cfn-init]/[user-data][ec2-user-data]. For example, the [Jira
quickstart template][jira-cfn-tmpl] creates a per-node [launch
configuration][ec2-launch-config] that fetches this repository and runs the
appropriate AWS/product playbook, which invokes the appropriate roles.

In practice, the Ansible roles require some information about the infrastructure
that was deployed (e.g. RDS endpoint/password). The way this is currently
achieved (on AWS) is that have the CloudFormation template dump this information
into the file `/etc/atl` as `RESOURCE_VAR=<resource>` lines. This can be then
sourced as environment variables to be retrieved at runtime. See the
helper-script `bin/ansible-with-atl-env` and the corresponding
`groups_vars/aws_node_local.yml` var-file.

## Customizing your deployment

To customise playbook behaviour, you can fork this repository and edit it as
needed. However, for one-off tasks you can also override the default and 
calculated settings with special values. To do this, provide command-line overrides to
[ansible-playbook](https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html).

The most likely use-case for this is to download a custom product distribution
for testing (for example, a pre-release version of Jira). If you are running `ansible-playbook`
directly, the command for this would look like the following:

    ansible-playbook \
        -e atl_product_download_url=http://s3.amazon.com/atlassian/jira-9.0.0-PRE-TEST.tar.gz \
        -e atl_use_system_jdk=true \
        -e atl_download_format=tarball \
        \
        -i inv/aws_node_local aws_jira_dc_node.yml

You can also do this on a CloudFormation template where the stack details are in `/etc/atl`.
On such templates, the variable `ATL_DEPLOYMENT_REPOSITORY_CUSTOM_PARAMS` is added to the
`ansible-playbook` parameters in `bin/ansible-with-alt-env`. In this case you
need to set it to:
    ATL_DEPLOYMENT_REPOSITORY_CUSTOM_PARAMS="-e atl_product_download_url=http://s3.amazon.com/atlassian/jira-9.0.0-PRE-TEST.tar.gz -e atl_use_system_jdk=true -e atl_download_format=tarball"


To set the same parameters in the AWS Quick Starts for
[Jira Data Center](https://aws.amazon.com/quickstart/architecture/jira/),
[Confluence Data Center](https://aws.amazon.com/quickstart/architecture/confluence/), and
[Bitbucket Data Center](https://aws.amazon.com/quickstart/architecture/bitbucket/), enter
them in the `Custom command-line parameters for Ansible` field:

    -e atl_product_download_url=http://s3.amazon.com/atlassian/jira-9.0.0-PRE-TEST.tar.gz -e atl_use_system_jdk=true -e atl_download_format=tarball

## Supported operating systems and environments

The roles in this repository currently target:

* Ansible-core 2.16
* Python >= 3.10 (as required by ansible-core 2.16)
* Amazon Linux 2023 and Debian 12+ (including derivatives, i.e., Ubuntu 22.04+) where the system-installable Python meets the above requirement

To use a previous version of this repository and the roles/playbooks within, your application nodes must clone/checkout
a previous commit that supports the desired OS and/or Ansible version. For instance, to continue using Ansible 2.13 on
Amazon Linux 2, use branch "ansible-core-2.13" and/or commit ID `e5af2cf649f72bb5c9d50d0057ddae4a5c99b6f9`. If using one
of the previously-provided AWS CloudFormation templates, you must set set the **Deployment Automation Branch** parameter
to "ansible-core-2.13" and/or manually set the stack's "pinned-ansible-sha" SSM Parameter to the referenced commit ID.

### Other customizable parameters

For more deployment customization options, consult the following files for parameters you can 
override:

- [`/roles/product_install/defaults/main.yml`](roles/product_install/defaults/main.yml)
- [`/group_vars/aws_node_local.yml`](group_vars/aws_node_local.yml)

More customizable parameters are defined in specific roles -- specifically, in the 
role's `defaults/main.yml` file. Most of these parameters use the `atl_` prefix. You can
use the following [Bitbucket code search query](https://confluence.atlassian.com/bitbucket/search-873876782.html) 
to find them:

    repo:dc-deployments-automation repo:dc-deployments-automation path:*/defaults/main.yml atl

### Custom files

* `jira-config.properties`: If this file exists in the shared home (default:
  `/media/atl/jira/shared/`) then it will be copied to the Jira local home
  directory (default: `/var/atlassian/application-data/jira/`). Note that this
  only happens on node creation; if you create or update the shared file it will
  need to be copied manually.

# Development and testing

See [Development](DEVELOPMENT.md) for details on setting up a development
environment and running tests.

# Roles philosophy

This suite is intended to consist of many small, composable roles that can
be combined together into playbooks. Wherever possible, roles should be product-agnostic
(e.g. downloads) and platform-agnostic. Functions that are product-specific or
platform-specific are split off into separate roles. 

Roles should be reasonably self-contained, with sensible defaults configured in
`/roles/<role>/defaults/main.yml`. Like all playbook parameters, you can override
them at runtime.

Some roles implicitly depend on other variables beind defined elsewhere.
For example, the `jira_config` role depends on the `atl_cluster_node_id`
var being defined; on AWS this is provided by the `aws_common` role, which
should be run first.


# Ansible layout

* Helper scripts are in `bin/`. In particular the `bin/ansible-with-atl-env`
  wrapper is of use during AWS node initialisation. Refer to the [Usage](#markdown-header-usage) section for
  more information.
* Inventory files are under `inv/`. For AWS `cfn-init` the inventory
  `inv/aws_node_local` inventory is probably what you want.
    * Note that this expects the environment to be setup with infrastructure information. 
      Refer to the [Usage](#markdown-header-usage) section for more information.
* Global group vars loaded automatically from `group_vars/<group>.yml`. In
  particular note `group_vars/aws_node_local.yml` which loads infrastructure
  information from the environment.
* Roles are defined in `roles/`
    * Platform specific roles start with `<platform-shortname>_...`, e.g. `roles/aws_common/`.
    * Similarly, product-specific roles should start with `<product>_...`.

# Reporting issues

If you find any bugs in this repository, or have feature requests or use cases
for us, please raise them in our [public Jira project](https://jira.atlassian.com/projects/SCALE/summary).

# License

Copyright © 2019 Atlassian Corporation Pty Ltd.
Licensed under the Apache License, Version 2.0.


[cfn-init]: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-init.html
[ec2-user-data]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
[jira-cfn-tmpl]: https://github.com/aws-quickstart/quickstart-atlassian-jira/blob/develop/templates/quickstart-jira-dc.template.yaml#L967
[ec2-launch-config]: https://docs.aws.amazon.com/autoscaling/ec2/userguide/LaunchConfiguration.html
