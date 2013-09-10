$codename = cat /etc/lsb-release | grep CODENAME | cut -f2 -d'='

sudo apt-get -y install software-properties-common
sudo add-apt-repository ppa:juju/stable
sudo apt-get update
sudo apt-get -y install juju-core lxc mongodb-server

mkdir -p ~/charm/$codename
git clone git@github.com:peterklipfel/storm_charm.git ~/charm/$codename/storm

sed s/notsosecret/`tr -dc "[:alpha:]" < /dev/urandom | head -c 30`/ local.yaml > environments.yaml
mkdir ~/.juju
mv environments.yaml ~/.juju/environments.yaml

sudo juju bootstrap
juju deploy zookeeper
juju deploy -v --repository=~/charm/ local:storm stormmaster
juju deploy -v --repository=~/charm/ local:storm stormworker

