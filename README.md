# Development Environment Setup

```
su
apt-get install sudo
adduser rob sudo
exit

ssh-keygen -t rsa -b 4096 -C "rob.acourt@gmail.com"
cat ~/.ssh/id_rsa.pub
echo "^^^ Add this to your git repo"

sudo apt install git
git clone git@github.com:robacourt/dev-env.git
cd dev-setup
./setup
```
