```bash

export USER="dev01"
export CLUSTER="rancher-desktop"

./create_kubeconfig.sh "${USER}" "${CLUSTER}"

kubectl get csr
kubectl config get-contexts

kubectl auth can-i get pod
kubectl auth can-i delete pod -n kube-system

kubectl delete "clusterrolebindings/admin-${USER}"

kubectl auth can-i get pod
kubectl auth can-i delete pod -n kube-system

unset KUBECONFIG
```
