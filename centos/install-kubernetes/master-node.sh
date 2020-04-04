#ssh into master
masterNode=$1
ssh masterNode

#initiate cluster using the ip range for Flannel
kubeadm init --pod-network-cidr=10.244.0.0/16

#copy the kubeadmin join command
# TODODODOD what does this mean?
#probably cat this out to a file kubeadmin-join-command.txt
#just write final routine into non-master-nodes.sh
echo "sudo" > non-master-nodes.sh
kubeadmin join >> non-master-nodes.sh
echo "kubectl get nodes" >> non-master-nodes.sh

#exit sudo
exit sudo
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

#deploy Flannel
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#check cluster state
kubectl get pods --all-namespaces
