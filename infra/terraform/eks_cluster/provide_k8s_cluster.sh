terraform apply --auto-approve

rm ~/.kube/config

aws eks update-kubeconfig --name mopic_k8s