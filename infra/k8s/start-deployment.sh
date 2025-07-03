kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/client/config/crd/snapshot.storage.k8s.io_volumesnapshots.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/rbac-snapshot-controller.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/deploy/kubernetes/snapshot-controller/setup-snapshot-controller.yaml

kubectl apply -f mopic_volume_snapshot_class.yaml
kubectl apply -f mopic_volume_snapshot_content.yaml
kubectl apply -f mopic_volume_snapshot.yaml

kubectl apply -f mopic_media_storage_class.yaml 
kubectl apply -f mopic_config_storage_class.yaml 
kubectl apply -f mopic_service.yaml
# kubectl apply -f mopic_persistent_volume.yaml 
kubectl apply -f mopic_volume_claim.yaml 
kubectl apply -f mopic_deployment.yaml