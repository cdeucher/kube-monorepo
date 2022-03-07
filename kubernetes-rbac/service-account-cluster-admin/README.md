
```bash
kubectl apply -f yaml/
./create_kubeconfig.sh

export KUBECONFIG=./kubeconfig-sa

kubectl get pods --all-namespaces
kubectl delete clusterrolebindings/admin

kubectl get pods --all-namespaces
kubectl get pods -n dev

unset KUBECONFIG
```

```bash
# https://docs.armory.io/armory-enterprise/armory-admin/manual-service-account/
```
