terraform apply --auto-approve

rm ~/.kube/config

doctl kubernetes cluster kubeconfig save mopic-k8s