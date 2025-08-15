.PHONY: app@up app@down localstack@up localstack@down localstack@auth s3@mb s3@rb 

app@up: 
	kubectl apply -f nodejs/app-configmap.yml \
	-f nodejs/app-secret.yml \
	-f nodejs/app-deployment.yml

app@down:
	kubectl apply -f nodejs/app-configmap.yml \
	-f nodejs/app-secret.yml \
	-f nodejs/app-deployment.yml

localstack@up:
	kubectl apply -f localstack/localstack-deployment.yml

localstack@down:
	kubectl delete -f localstack/localstack-deployment.yml

localstack@auth: 
	kubectl get po -l app=localstack --no-headers | awk '{print $$1}' | while read pod; do \
		kubectl exec -it "$$pod" -- sh -c 'mkdir -p ~/.aws && touch ~/.aws/config && touch ~/.aws/credentials' && \
		kubectl exec -it "$$pod" -- sh -c 'printf "[profile localstack]\nregion=us-east-1\noutput=json\nendpoint_url = http://localhost:4566\n" > ~/.aws/config && \
			printf "[localstack]\naws_access_key_id=test\naws_secret_access_key=test\n" > ~/.aws/credentials'; \
	done

s3@mb:
	kubectl get po -l app=localstack --no-headers | awk '{print $$1}' | while read pod; do \
		kubectl exec -it "$$pod" -- sh -c 'aws s3 mb s3://nodejs-bucket --profile localstack'; \
	done

s3@rb:
	kubectl get po -l app=localstack --no-headers | awk '{print $$1}' | while read pod; do \
		kubectl exec -it "$$pod" -- sh -c 'aws s3 rb s3://nodejs-bucket --profile localstack'; \
	done
