The goal of this is to prepare a device to be the SOLE master node for our clusters. This does rely on at least one device being hand configured.
This is needed for tinkerbell and can be used to manage our VPS set-up


```
# Make sure APT is ready
sudo apt-get update

# To run containers
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Install K8 requirements
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Mark these to not be updated by APT on apt-get update operations
sudo apt-mark hold kubelet kubeadm kubectl

# Disable swap
sudo swapoff -a

# Start master node
# Sets range for 192.0.0.0 to 192.254.254.254
sudo kubeadm init --pod-network-cidr=192.0.0.0/8

# Sets up kubectl to use our cluster
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

```

# Network add-on
This is just a pre-configured YAML for Canal, but Canal provides a great deal of control
It is decently suited for just about every configuration setup, and it gives you insight
on the other two network add-ons since it relies on both. (Canal and Flannel)
```
kubectl apply -f https://docs.projectcalico.org/manifests/canal.yaml
```



```
# Post init

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.3.40:6443 --token some-token \
        --discovery-token-ca-cert-hash sha256:some-hash
```