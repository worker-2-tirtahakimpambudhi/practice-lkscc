.PHONY: storage@up storage@down mysql@up mysql@down wp@up wp@down openebs@up openebs@down

openebs@up: 
	helm install openebs openebs/openebs \
	--set engines.replicated.mayastor.enabled=false \
	--set engines.local.lvm.enabled=false \
	--set engines.local.zfs.enabled=false \
	--namespace openebs \
	--create-namespace

openebs@down: 
	helm uninstall openebs -n openebs 

storage@up: 
	minikube ssh -- sudo mkdir -p /data/volumes/wordpress/{mysql,wp}
	kubectl apply -f storage.yml

storage@down: 
	minikube ssh -- sudo rm -rf /data/volumes/wordpress/{mysql,wp}
	kubectl delete -f storage.yml

mysql@up:
	kubectl apply -f mysql/mysql-volume.yml -f mysql/mysql-config.yml -f mysql/mysql-configmap.yml -f mysql/mysql-secret.yml -f mysql/mysql-deployment.yml

mysql@down:
	kubectl delete -f mysql/mysql-volume.yml -f mysql/mysql-config.yml -f mysql/mysql-configmap.yml -f mysql/mysql-secret.yml -f mysql/mysql-deployment.yml

wp@up: 
	kubectl apply -f wp/wp-volume.yml -f wp/wp-configmap.yml -f wp/wp-secret.yml -f wp/wp-deployment.yml

wp@down: 
	kubectl delete -f wp/wp-volume.yml -f wp/wp-configmap.yml -f wp/wp-secret.yml -f wp/wp-deployment.yml