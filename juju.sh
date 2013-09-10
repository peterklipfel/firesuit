$codename = cat /etc/lsb-release | grep CODENAME | cut -f2 -d'='

sudo apt-get install software-properties-common
sudo add-apt-repository ppa:juju/stable
sudo apt-get update
sudo apt-get install juju-core lxc mongodb-server

mkdir -p ~/charm/$codename
git clone git@github.com:peterklipfel/storm_charm.git ~/charm/$codename/storm

