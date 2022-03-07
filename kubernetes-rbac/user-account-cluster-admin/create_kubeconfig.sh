#!/bin/bash

if [[ -z "${1}" || -z "${2}" ]] ; then
  print "user-account/cluster are required\n"
fi

export SA="${1}"
export CLUSTER="${2}"
export CONTEXT=$(kubectl config current-context)

openssl genrsa -out "${SA}.key" 2048

openssl req -new -key "${SA}.key" -out "${SA}.csr" -subj "/CN=${SA}/O=my"

printf "${SA}\n"

printf "
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: "cert-${SA}"
spec:
  request: xx
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # one day
  usages:
  - client auth
" > cert-request.yml

# MAC, replace -ibackp -> -i 
sed -i.backp "s?xx?$(cat "${SA}.csr" | base64)?g" cert-request.yml

kubectl apply -f cert-request.yml
kubectl certificate approve "cert-${SA}"
kubectl get csr "cert-${SA}" -o jsonpath='{.status.certificate}'| base64 -d > "${SA}.crt"
kubectl config set-credentials "${SA}" --client-key="${SA}.key" --client-certificate="${SA}.crt" --embed-certs=true

kubectl create role developer --verb=create --verb=get --verb=list --verb=update --verb=delete --resource=pods
kubectl create rolebinding developer-binding-"${SA}" --role=developer --user="${SA}"

kubectl create clusterrolebinding --clusterrole cluster-admin --user="${SA}"  "admin-${SA}"

kubectl config set-context "${SA}" --cluster="${CLUSTER}" --user="${SA}"
kubectl config use-context "${SA}"

kubectl config view --flatten --minify > KUBECONFIG_FILE_CERT_"${SA}"

kube config use-context "${CONTEXT}"

printf "
---------------------------------
export KUBECONFIG=./KUBECONFIG_FILE_CERT_${SA}
"
