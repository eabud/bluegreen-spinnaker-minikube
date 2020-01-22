#!/usr/bin/env bash

# update packages
echo "Updating System"
  sudo yum update -y && sudo yum upgrade -y
  sudo yum install -y socat # used for kubectl port-forwarding
  sudo yum install git -y

echo "Installing kubectl..."
  curl -LO curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.13.7/bin/linux/amd64/kubectl
  chmod +x ./kubectl
  sudo mv ./kubectl /usr/bin/kubectl

echo "Installing docker..."
  sudo yum install docker -y

echo "Installing minikube..."
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  chmod +x minikube
  sudo mv minikube /usr/bin/

echo "Starting docker..."
   sudo service docker start

echo "Starting minikube..."
  sudo minikube config set vm-driver none
  sudo minikube config set kubernetes-version v1.13.7
  sudo minikube delete
  sudo minikube start # sudo because none driver requires root privileges

echo "Checking minikube status..."
  sudo minikube status
  sudo minikube kubectl version

echo "Installing helm chart..."
  export HELM_INSTALL_DIR="/usr/bin"
  curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get > get_helm.sh
  chmod +x get_helm.sh
  sh get_helm.sh
  sudo helm init --wait
  sudo rm get_helm.sh

echo "Clone Spinnaker helm chart..."
  git clone https://github.com/helm/charts.git
  cd charts
  git fetch origin pull/18545/head
  git checkout -b pullrequest FETCH_HEAD
  cd stable/spinnaker

  # update helm dependency
  sudo helm dependency update

echo "Install spinnaker helm chart for namespace default..."
  sudo helm install --set ingress.enabled=True --name spinnaker --namespace default . --timeout 600

  # port forwarding for spin-deck and spin-gate to be used outside of kubernetes cluster
  sudo kubectl wait --for=condition=Ready pod/$(sudo kubectl get pods --namespace default -l "cluster=spin-deck" -o jsonpath="{.items[0].metadata.name}") --namespace default --timeout=300s
  sudo kubectl port-forward --namespace default $(sudo kubectl get pods --namespace default -l "cluster=spin-deck" -o jsonpath="{.items[0].metadata.name}") 9000 &
  sudo kubectl wait --for=condition=Ready pod/$(sudo kubectl get pods --namespace default -l "cluster=spin-gate" -o jsonpath="{.items[0].metadata.name}") --namespace default --timeout=300s
  sudo kubectl port-forward --namespace default $(sudo kubectl get pods --namespace default -l "cluster=spin-gate" -o jsonpath="{.items[0].metadata.name}") 8084 &

  # export ports and public ip to be used later
  export public_ip="$(curl http://checkip.amazonaws.com)"
  export spin_deck_port="$(sudo kubectl get service spin-deck -n default -o go-template='{{index (index .spec.ports 0) "nodePort" }}')"
  export spin_gate_port="$(sudo kubectl get service spin-gate -n default -o go-template='{{index (index .spec.ports 0) "nodePort" }}')"

  cd ~
  sudo mkdir .spin
  sudo cat > config.yaml << EOF
gate:
  endpoint: http://127.0.0.1:${spin_gate_port}
EOF
  sudo mv config.yaml .spin/

echo "Installing Spinnaker CLI..."
  sudo curl -LO https://storage.googleapis.com/spinnaker-artifacts/spin/$(curl -s https://storage.googleapis.com/spinnaker-artifacts/spin/latest)/linux/amd64/spin
  sudo chmod +x spin
  sudo mv spin /usr/bin/

echo "Creating helloworld service in kubernetes "
  sudo kubectl apply -f /tmp/hellosvc.yaml -n default

echo "Apply replicasets helloworld in kubernetes "
  sudo kubectl apply -f /tmp/replicaset-v1.yaml -n default

echo "Creating the pipeline in Spinnaker and triggering an execution"

  sudo spin pipeline save -f /tmp/pipeline.json | grep 'succeeded' &> /dev/null

  while [ $? != 0 ]
  do
     echo "will try again in 300 seconds ..."
     sleep 300
     sudo spin pipeline save -f /tmp/pipeline.json | grep 'succeeded' &> /dev/null
   done


  sudo spin pipeline execute --name bluegreen --application helloworld

  export helloworld_port="$(sudo kubectl get service hellosvc -n default -o go-template='{{index (index .spec.ports 0) "nodePort" }}')"

  echo "Congratulation! Spinnaker admin console : http://${public_ip}:${spin_deck_port}"
  echo "Hello World Pipeline                    : http://${public_ip}:${spin_deck_port}/#/applications/helloworld"
  echo "Hello World application                 : http://${public_ip}:${helloworld_port}"