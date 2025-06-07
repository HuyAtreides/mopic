kubectl apply -f mopic_media_storage_class.yaml 
kubectl apply -f mopic_config_storage_class.yaml 
kubectl apply -f mopic_service.yaml
# kubectl apply -f mopic_persistent_volume.yaml 
kubectl apply -f mopic_volume_claim.yaml 
kubectl apply -f mopic_deployment.yaml