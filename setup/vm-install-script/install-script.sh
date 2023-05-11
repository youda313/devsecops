#!/bin/bash
#tested on Linux ubuntu-host 5.4.0-1104-gcp #113~18.04.1-Ubuntu
set -e

echo ".........----------------#################._.-.-INSTALL-.-._.#################----------------........."
PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$'
echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$'" >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc
source ~/.bashrc

sudo apt-get autoremove -y  #removes the packages that are no longer needed
sudo apt-get update
sudo systemctl daemon-reload

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo sh -c 'echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" >> /etc/apt/sources.list.d/kubernetes.list'

KUBE_VERSION=1.26.3
#sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf | true
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y kubelet=${KUBE_VERSION}-00 wget vim build-essential jq python3-pip kubectl=${KUBE_VERSION}-00 runc kubernetes-cni=1.2.0-00 kubeadm=${KUBE_VERSION}-00
sudo apt-mark hold kubeadm kubectl kubelet


### UUID of VM 
### comment below line if this Script is not executed on Cloud based VMs
#pip3 install jc
#sudo apt install dmidecode
#jc dmidecode | jq .[1].values.uuid -r


#REMOVING CONTAINERD to replace it by DOCKER below
#wget https://github.com/containerd/containerd/releases/download/v1.7.0/containerd-1.7.0-linux-amd64.tar.gz
#sudo tar Czxvf /usr/local containerd-1.7.0-linux-amd64.tar.gz
#wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
#mkdir -p /usr/lib/systemd/system
#mv containerd.service /usr/lib/systemd/system/
#mkdir -p /etc/containerd/
#containerd config default > /etc/containerd/config.toml
#sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
#crictl config runtime-endpoint unix:///var/run/containerd/containerd.sock
#echo "alias docker='crictl'" > /etc/profile.d/00-alises.sh
#alias docker='crictl'

#INSTALL DOCKER-CE
#https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04

sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update 
sudo apt install docker-ce -y
sudo usermod -aG docker ${USER}

sudo systemctl daemon-reload
sudo systemctl enable --now docker
sudo systemctl start docker
#systemctl enable --now containerd

sudo systemctl enable kubelet
sudo systemctl start kubelet

echo ".........----------------#################._.-.-KUBERNETES-.-._.#################----------------........."
# sudo rm /root/.kube/config | true
# sudo kubeadm reset -f
sudo modprobe br_netfilter
sudo sed -i 's/^#\(net\.ipv4\.ip_forward=1\)/\1/' /etc/sysctl.conf
sudo sysctl -w net.ipv4.ip_forward=1
# DISABLED No SWAP enabled on cloud machines
# sudo sed -i '/ swap / s/^ (.*)$/#1/g' /etc/fstab
# sudo swapoff -a

sudo rm -rf /etc/containerd/config.toml
sudo systemctl restart containerd


# Initialize kubernetes cluster
#sudo kubeadm init --kubernetes-version=${KUBE_VERSION} --skip-token-print
sudo kubeadm init --pod-network-cidr=10.244.10.0/16 --kubernetes-version=${KUBE_VERSION} --skip-token-print

# uncomment below line if your host doesnt have minimum requirement of 2 CPU
# kubeadm init --kubernetes-version=${KUBE_VERSION} --ignore-preflight-errors=NumCPU --skip-token-print

mkdir -p ~/.kube
sudo cp -f /etc/kubernetes/admin.conf ~/.kube/config
ORIGINAL_USERNAME=$USER
sudo chown $ORIGINAL_USERNAME ~/.kube/config

kubectl apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml"
echo "Waiting 60 seconds"
sleep 60

echo "untaint controlplane node"
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl get node -o wide

echo ".........----------------#################._.-.-Java and MAVEN-.-._.#################----------------........."


sudo mkdir -p /usr/share/man/man1
sudo apt install openjdk-11-jdk -y 

echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/myenvvars.sh
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/myenvvars.sh
echo 'source ~/myenvvars.sh' >> ~/.bashrc
source ~/.bashrc
java -version


sudo apt install -y maven
mvn -v

echo ".........----------------#################._.-.-JENKINS-.-._.#################----------------........."
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install -y jenkins
#if port 8080 already taken
#sudo sed -i 's/HTTP_PORT=8080/HTTP_PORT=8081/g' /lib/systemd/system/jenkins.service
sudo sed -i 's/JENKINS_PORT=8080/JENKINS_PORT=8081/g' /lib/systemd/system/jenkins.service

sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins --no-pager
echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

echo ".........----------------#################._.-.-COMPLETED-.-._.#################----------------........."
