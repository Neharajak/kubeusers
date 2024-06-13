#!/bin/bash
### Usage: ####
# ./genUser.sh <user> <days> 
# kubectl create clusterrolebinding bob-admin --clusterrole=cluster-admin --user=bob
# kubectl create -n <namespace> rolebinding bob-admin --clusterrole=admin --user=bob

USER=$1  # name of the user, key, csr and certificate
DAYS=$2

# CA_PATH=/etc/kubernetes/pki
CA_PATH='.'
CA_CERT=$CA_PATH/ca.crt
CA_KEY=$CA_PATH/ca.key

CPATH='.'
CLIENT_KEY=$CPATH/$USER.key
CLIENT_CSR=$CPATH/$USER.csr
CLIENT_CRT=$CPATH/$USER.crt
GROUP='freelancer'
BITS=4096

if [ ! -e $CA_CERT ]; then
   echo "Unable to locate Kubernetes CA - $CA_CERT file"; exit 1;
fi

if [[ "$#" -lt 2 ]]; then
    echo "Usage: $0 <userid> <valid-for-days>"
    exit 1
fi
if [ $DAYS=='' ]; then 
     DAYS=1
fi

CLUSTERENDPOINT=$(kubectl config view | grep server | cut -f 2- -d ":" | tr -d " ")
CLUSTERNAME=$(kubectl config get-clusters | sed -n '2p') 

# useradd -m ${USER} 
# mkdir -p $CPATH/$USER/.kube && cd $CPATH/$USER
openssl genrsa -out $CLIENT_KEY $BITS
openssl req -new -key $CLIENT_KEY -out $CLIENT_CSR -subj "/O=$GROUP/CN=$USER"
openssl x509 -req -days $DAYS -sha256 -in $CLIENT_CSR -CA $CA_CERT -CAkey $CA_KEY -set_serial 2 -out $CLIENT_CRT

cat <<-EOF > $USER-kubeconfig.usr
apiVersion: v1
kind: Config
preferences:
  colors: true
current-context: $CLUSTERNAME
clusters:
- name: $CLUSTERNAME
  cluster:
    server: $CLUSTERENDPOINT
    certificate-authority-data: $(cat $CA_CERT | base64 --wrap=0)
contexts:
- context:
    cluster: $CLUSTERNAME
    user: $USER
  name: $CLUSTERNAME
users:
- name: $USER
  user:
    client-certificate-data: $(cat $CLIENT_CRT | base64 --wrap=0)
    client-key-data: $(cat $CLIENT_KEY | base64 --wrap=0)
EOF
## chown -R $USER:$USER /home/$USER
##end
