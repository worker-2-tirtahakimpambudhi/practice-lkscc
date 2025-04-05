.PHONY: storage@up storage@down mysql@up mysql@down go@up go@down redis@up redis@down

storage@up: 
	minikube ssh -- sudo mkdir -p /data/volumes/go-health/{mysql,go,redis}
	kubectl apply -f storage.yml

storage@down: 
	minikube ssh -- sudo rm -rf /data/volumes/go-health/{mysql,go,redis}
	kubectl delete -f storage.yml

mysql@up:
	kubectl apply -f mysql/mysql-volume.yml -f mysql/mysql-config.yml -f mysql/mysql-configmap.yml -f mysql/mysql-secret.yml -f mysql/mysql-deployment.yml

mysql@down:
	kubectl delete -f mysql/mysql-volume.yml -f mysql/mysql-config.yml -f mysql/mysql-configmap.yml -f mysql/mysql-secret.yml -f mysql/mysql-deployment.yml

go@up: 
	kubectl apply -f go/go-volume.yml -f go/go-configmap.yml -f go/go-secret.yml -f go/go-deployment.yml

go@down: 
	kubectl delete -f go/go-volume.yml -f go/go-configmap.yml -f go/go-secret.yml -f go/go-deployment.yml