# Copyright 2013 Canonical Ltd.
#
# Authors:
#  Charm Helpers Developers <juju@lists.ubuntu.com>
"""A helper to create a yaml cache of config with namespaced relation data."""
import os
import yaml

import charmhelpers.core.hookenv


charm_dir = os.environ.get('CHARM_DIR', '')


def juju_state_to_yaml(yaml_path, namespace_separator=':',
                       allow_hyphens_in_keys=True):
    """Update the juju config and state in a yaml file.

    This includes any current relation-get data, and the charm
    directory.

    This function was created for the ansible and saltstack
    support, as those libraries can use a yaml file to supply
    context to templates, but it may be useful generally to
    create and update an on-disk cache of all the config, including
    previous relation data.

    By default, hyphens are allowed in keys as this is supported
    by yaml, but for tools like ansible, hyphens are not valid [1].

    [1] http://www.ansibleworks.com/docs/playbooks_variables.html#what-makes-a-valid-variable-name
    """
    config = charmhelpers.core.hookenv.config()

    # Add the charm_dir which we will need to refer to charm
    # file resources etc.
    config['charm_dir'] = charm_dir
    config['local_unit'] = charmhelpers.core.hookenv.local_unit()

    # Add any relation data prefixed with the relation type.
    relation_type = charmhelpers.core.hookenv.relation_type()
    if relation_type is not None:
        relation_data = charmhelpers.core.hookenv.relation_get()
        relation_data = dict(
            ("{relation_type}{namespace_separator}{key}".format(
                relation_type=relation_type.replace('-', '_'),
                key=key,
                namespace_separator=namespace_separator), val)
            for key, val in relation_data.items())
        config.update(relation_data)

    # Don't use non-standard tags for unicode which will not
    # work when salt uses yaml.load_safe.
    yaml.add_representer(unicode, lambda dumper,
                         value: dumper.represent_scalar(
                             u'tag:yaml.org,2002:str', value))

    yaml_dir = os.path.dirname(yaml_path)
    if not os.path.exists(yaml_dir):
        os.makedirs(yaml_dir)

    if os.path.exists(yaml_path):
        with open(yaml_path, "r") as existing_vars_file:
            existing_vars = yaml.load(existing_vars_file.read())
    else:
        existing_vars = {}

    if not allow_hyphens_in_keys:
        config = dict(
            (key.replace('-', '_'), val) for key, val in config.items())
    existing_vars.update(config)
    with open(yaml_path, "w+") as fp:
        fp.write(yaml.dump(existing_vars))
