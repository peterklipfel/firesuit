codename=`cat /etc/lsb-release | grep CODENAME | cut -f2 -d'='`

# sudo apt-get -y install software-properties-common
# if [[ `grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep juju/stable` ]]; then
#   echo 'ppa has already been added'
# else
#   echo 'adding ppa'
#   sudo add-apt-repository ppa:juju/stable
# fi

# sudo apt-get update
# if [[ "$codename" == "precise" ]]; then
#   sudo apt-get install juju-local linux-image-generic-lts-raring linux-headers-generic-lts-raring
# else
#   sudo apt-get install juju-local
# fi

# mkdir -p ~/charm/$codename
# mkdir -p ~/charm/precise
# git clone git@github.com:peterklipfel/storm_charm.git ~/charm/$codename/storm
# git clone git@github.com:peterklipfel/storm_charm.git ~/charm/precise/storm


# sed s/notsosecret/`tr -dc "[:alpha:]" < /dev/urandom | head -c 30`/ local.yaml > environments.yaml
# mkdir ~/.juju
# mv environments.yaml ~/.juju/environments.yaml

# juju switch local

# sudo juju bootstrap
juju deploy zookeeper
juju deploy -v --repository=/home/$USER/charm/ local:storm stormmaster
juju deploy -v --repository=/home/$USER/charm/ local:storm stormworker
# juju deploy cassandra
# juju deploy cs:precise/rabbitmq-server

juju add-relation stormmaster zookeeper
juju add-relation stormworker zookeeper
juju add-relation stormmaster:master stormworker:worker
juju expose stormmaster
juju expose stormworker
