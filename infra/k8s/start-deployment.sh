kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.1/nvidia-device-plugin.yml
kubectl apply -f mopic_storage_class.yaml 
kubectl apply -f mopic_service.yaml
# kubectl apply -f mopic_persistent_volume.yaml 
kubectl apply -f mopic_volume_claim.yaml 
kubectl apply -f mopic_deployment.yaml