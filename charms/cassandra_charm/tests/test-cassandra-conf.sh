#!/bin/bash
# Author: JuanJo Ciarlante <jjo@canonical.com>
# License: GPLv3
# Copyright 2013, Canonical Ltd.
#
# Test cassandra-env.sh, and cassandra.yaml edits by
# cassandra charm hooks.
set -i
BASEDIR="$PWD"
test_set_config() {
    CONFIG["$1"]="$2"
}
init_test_files() {
    CASSANDRA_ENV_REF="${BASEDIR}/cassandra-${VERSION}/conf/cassandra-env.sh"
    CASSANDRA_YML_REF="${BASEDIR}/cassandra-${VERSION}/conf/cassandra.yaml"
    if [ $(id -u) -eq 0 ]; then
        echo "ERROR: denying to continue as root"
        exit 255
    fi
    case "${ETC_CASSANDRA}" in
        /etc/*) echo "ERROR: denying to continue with $ETC_CASSANDRA=/etc/*"; exit 255;;
    esac
    rm -f ${ETC_CASSANDRA}/*
    cp -p ${CASSANDRA_ENV_REF} ${CASSANDRA_ENV}
    cp -p ${CASSANDRA_YML_REF} ${CASSANDRA_YML}
}
remove_test_files() {
    rm -f ${ETC_CASSANDRA}/*
}
init_config() {
    while read key val;do
        test_set_config ${key} "${val}"
    done < <(python -c '
import yaml, sys
opts=yaml.load(sys.stdin)["options"]
print "\n".join(["{} {}".format(o, opts[o].get("default")) for o in opts])' \
            < ${BASEDIR}/../config.yaml)
}
source_charm_code() {
    export CASSANDRA_TESTING=True
    pushd .. >/dev/null
    source ./hooks/cassandra-common
    popd >/dev/null
}
echo_var() {
    local varname="${1?}"
    bash -c "(. ${CASSANDRA_ENV} >/dev/null; echo \"\$${varname}\")"
}
grep_var() {
    local varname="${1?}" value="${2?}"
    echo_var "${varname}" | egrep -q -- "${value}"
}
echo_yml_expression() {
    python -c "import yaml,sys;print yaml.load(sys.stdin)$1" < ${CASSANDRA_YML}
}
echo_yml_entry() {
    echo_yml_expression "[\"$1\"]"
}
exp_ok() {
    "$@" && return 0 || { echo "ERROR: ${FUNCNAME[1]}: $@ -> $?!=0)" >&2; exit 1;}
}
exp_nok() {
    "$@" || return 0 && { echo "ERROR: ${FUNCNAME[1]}: $@ -> 0!=nonzero)" >&2; exit 1;}
}
# Tests BEGIN
simple_validate_files() {
    bash -n $CASSANDRA_ENV
    python -c 'import yaml, sys; yaml.load(sys.stdin)' < $CASSANDRA_YML
}
test_simpleauth() {
    local passwd_value="user=fooPassWoRd${RANDOM}"
    local access_value="someArbiTRARY<>content${RANDOM}"
    # True
    test_set_config use-simpleauth True
    test_set_config auth-passwd64 "$(echo "${passwd_value}"|base64)"
    test_set_config auth-access64 "$(echo "${access_value}"|base64)"
    hook_main config-changed 2>&1 || exit 1
    exp_ok grep_var JVM_OPTS "-D(access|passwd).properties"
    exp_ok cmp -s <(echo "${passwd_value}") $CASSANDRA_PASSWD
    exp_ok cmp -s <(echo "${access_value}") $CASSANDRA_ACCESS
    exp_ok test $(stat -c %a "${CASSANDRA_PASSWD}") -eq 600
    exp_ok simple_validate_files
    # False
    test_set_config use-simpleauth False
    hook_main config-changed 2>&1 || exit 1
    exp_nok grep_var JVM_OPTS "-D(access|passwd).properties"
    exp_nok test -f $CASSANDRA_PASSWD
    exp_nok test -f $CASSANDRA_ACCESS
    exp_ok simple_validate_files
}
test_extra_jvm_opts() {
    # Test adding something
    local value="-DFOO=bar -DBAR=baz"
    test_set_config extra-jvm-opts "${value}"
    hook_main config-changed 2>&1 || exit 1
    # grep for $value addition to JVM_OPTS
    exp_ok grep_var JVM_OPTS "${value}"
    # unsetting must remove extra opts
    test_set_config extra-jvm-opts ""
    hook_main config-changed 2>&1 || exit 1
    exp_nok grep_var JVM_OPTS "${value}"
    exp_ok simple_validate_files
}
test_endpoint_snitch() {
    test_set_config endpoint_snitch org.apache.cassandra.locator.GossipingPropertyFileSnitch
    hook_main config-changed 2>&1 || exit 1
    exp_ok test -f ${CASSANDRA_RACKDC}
    exp_ok egrep -q dc= ${CASSANDRA_RACKDC}
    exp_ok egrep -q rack= ${CASSANDRA_RACKDC}
    # Test above, with short names
    test_set_config endpoint_snitch SimpleSnitch
    test_set_config endpoint_snitch GossipingPropertyFileSnitch
    hook_main config-changed 2>&1 || exit 1
    exp_ok test -f ${CASSANDRA_RACKDC}
    exp_ok egrep -q dc= ${CASSANDRA_RACKDC}
    exp_ok egrep -q rack= ${CASSANDRA_RACKDC}
    exp_ok simple_validate_files
}
test_force_seed_nodes() {
    local value=some.forced-node
    # Check setting it
    test_set_config force-seed-nodes "${value}"
    hook_main config-changed 2>&1 || exit 1
    exp_ok test $(echo_yml_expression '["seed_provider"][0]["parameters"][0]["seeds"]') = "${value}"
    # and un-setting
    test_set_config force-seed-nodes ""
    hook_main config-changed 2>&1 || exit 1
    exp_ok test x$(echo_yml_expression '["seed_provider"][0]["parameters"][0]["seeds"]') = x
}
test_units_to_update() {
    # Change something
    local value1="-DFOO=BAR"
    local value2="-DBAZ=ZOO"
    JUJU_UNIT_NAME="cassandra-test/0"
    # Test my unitnum not to be updated
    test_set_config extra-jvm-opts "${value1}"
    test_set_config units-to-update "1,2"
    hook_main config-changed 2>&1 || exit 1
    exp_nok grep_var JVM_OPTS "${value1}"
    # Test my unitnum to be updated
    test_set_config units-to-update "0,5"
    hook_main config-changed 2>&1 || exit 1
    exp_ok grep_var JVM_OPTS "${value1}"
    # Test "all", with a new value
    test_set_config extra-jvm-opts "${value2}"
    test_set_config units-to-update "all"
    hook_main config-changed 2>&1 || exit 1
    exp_ok grep_var JVM_OPTS "${value2}"
}
test_jmx_port() {
    local value="12345"
    test_set_config jmx-port "${value}"
    configure_jmx_port 2>&1 || exit 1
    exp_ok test "${value}" -eq $(echo_var JMX_PORT)
    exp_ok simple_validate_files
}
test_srv_root() {
    local value="${WORKDIR}/srv/path/root"
    # Charm does chown cassandra:cassandra
    chown() { true; }
    srv_root_save "${value}"
    exp_ok test -d "${value}"
    exp_ok test "['${value}/data']" = $(echo_yml_entry data_file_directories)
    exp_ok test "${value}/savedcache_dir" = "$(echo_yml_entry saved_caches_directory)"
    exp_ok test "${value}/commitlog" = $(echo_yml_entry commitlog_directory)
    exp_ok test "${value}" = "$(srv_root_get)"
}
test_compaction_throughput() {
    local value=0
    test_set_config compaction-throughput ${value}
    hook_main config-changed 2>&1 || exit 1
    exp_ok test $(echo_yml_entry compaction_throughput_mb_per_sec) = ${value}
}
test_stream_throughput() {
    local value=0
    test_set_config stream-throughput ${value}
    hook_main config-changed 2>&1 || exit 1
    exp_ok test $(echo_yml_entry stream_throughput_outbound_megabits_per_sec) = ${value}
}

# Tests END
# main():
ACTION=${1:?}
VERSION=${2}
shift 2
TESTS="$@"
[[ $TESTS == all ]] && \
TESTS=(test_simpleauth test_extra_jvm_opts test_jmx_port test_srv_root
       test_units_to_update test_endpoint_snitch test_force_seed_nodes
       test_compaction_throughput test_stream_throughput)
case "$ACTION" in
    clean)  rm -rf ${TMPDIR:-/tmp}/${USER}-test-cassandra.*; exit $?;;
    test)   ;; # Let it thru
    *)      exit 255;;
esac
WORKDIR=$(mktemp -p "${TMPDIR:-/tmp}" -d ${USER}-test-cassandra.XXXXXXX)
export ETC_CASSANDRA=$WORKDIR/etc
mkdir -p ${ETC_CASSANDRA}
# Create fake environment (juju and other cmds)
declare -A CONFIG
JUJU_UNIT_NAME="cassandra-test/0"
open-port()    { echo "DRY: open-port $@"; }
config-get()   { eval echo "\${CONFIG[$1]}"; }
unit-get()     { echo "$JUJU_UNIT_NAME"; }
juju-log()     { echo "$@" ;}
relation-get() { echo "" ;}
bzr()          { echo "DRY: bzr $@"; }
dig()          { [[ ${FUNCNAME[1]} == get_private_ip ]] && echo "127.0.0.99" ;}
source_charm_code
CASSANDRA_USER=$(id -nu)
CASSANDRA_GROUP=$(id -ng)
cd ${WORKDIR} || exit 1
typeset -i n=0
for t in ${TESTS[@]}
    do
        init_config
        init_test_files
        logfile=${WORKDIR}/${t}.log
        logerr=${WORKDIR}/${t}.err
        echo -n "$t: ..."
        if (echo "Running $t";$t) > ${logfile} 2> ${logerr} ;then
            echo -e "\rPASS: $VERSION $t"
            rm -f ${logfile}
        else
            ((n=n+1))
            etc_saved=${WORKDIR}/${t}.etc-saved
            mkdir ${etc_saved}
            cp -p ${ETC_CASSANDRA}/* ${etc_saved}
            echo -e "\rFAIL: $VERSION $t: $(egrep ^ERROR: ${logerr}|tail -1)\nSee: ${logfile} ${logerr} ${etc_saved})"
        fi
        remove_test_files
done
[[ n == 0 ]] && rm -rf ${WORKDIR}
exit $n
# vim: et:sw=4:ts=4:si
