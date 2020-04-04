# Run this on every machine in the system.

#ssh into machine
#need user@ip host as argument $1
targetMachine=$1
ssh $targetMachine

#must be sudo
sudo su

#NEVER DO THIS IN PRODUCTION
#disable SELinux
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#enable br_netfilter module for cluster communication
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#disable swap to prevent memory allocation issues
swapoff -a
head -n -1 /etc/fstab >> temp.txt 
cat temp.txt > /etc/fstab
echo "#/root/swap swap swap sw 0 0" >> /etc/fstab

# install docker prereq
yum install -y yum-utils device-mapper-persistent-data lvm2

#add docker repo and install docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce

#configure the docker cgroup driver to systemd, enable and start docker
sed -i '/^ExecStart/ s/$/ --exec-opt native.cgroupdriver=systemd/' /usr/lib/systemd/system/docker.service 
systemctl daemon-reload
systemctl enable docker --now 
systemctl status docker
docker info | grep -i cgroup

#add the kubernetes repo
djflskdjflksdjflkat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
      https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

#install kubernetes
yum install -y kubelet kubeadm kubectl

#enable kubernetes
systemctl enable kubelet
