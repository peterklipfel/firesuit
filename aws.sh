codename=`cat /etc/lsb-release | grep CODENAME | cut -f2 -d'='`

sudo apt-get -y install software-properties-common
sudo add-apt-repository ppa:juju/stable
sudo apt-get update
sudo apt-get -y install juju-core lxc mongodb-server

echo "preparing orchsetration environment"
sed s/notsosecret/`tr -dc "[:alpha:]" < /dev/urandom | head -c 30`/ aws.yaml > tmp.yaml
sed s/notsounique/`tr -dc "[:alpha:]" < /dev/urandom | head -c 30`/ tmp.yaml > uniquified.yaml
rm tmp.yaml
echo "Type your amazon access key, followed by [ENTER]:"
read access_key
echo "Type your amazon secret key, followed by [ENTER]:"
read secret_key
sed s/youraccesskey/$access_key/ uniquified.yaml > tmp.yaml
sed s/yoursecretkey/$secret_key/ tmp.yaml > environments.yaml
rm tmp.yaml
rm uniquified.yaml
mkdir ~/.juju
mv environments.yaml ~/.juju/environments.yaml

echo "setting up firesuit"
sudo ln -s `pwd`/lib/firesuit /usr/bin/firesuit

echo "generating ssh keys"
ssh-keygen -t rsa -C "firesuit@master"

