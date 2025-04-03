# TODO
- Create Deployment Wordpress
- Create Service Wordpress
- Create Ingress Load Balance with External DNS 
- Create Service Account and Role

# WARNING
THE USERS RUN THE EKSCTL MUST BE MINIMUM IAM [EKSCTL](https://eksctl.io/usage/minimum-iam-policies/)

# AFTER APPLY KONFIGURATION PLEASE UPDATE KUBECTL CONFIG WITH
[Update Kubeconfig](https://docs.aws.amazon.com/id_id/eks/latest/userguide/create-kubeconfig.html)

[AWS EKS INGRESS ALB](https://harsh05.medium.com/path-based-routing-with-aws-load-balancer-controller-an-ingress-journey-on-amazon-eks-733d3c6c5adf)

### Policy AWS ALB
```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json


# Requirement account have iam policy full access
aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://iam_policy.json
```

### Add EKS Repository Helm
```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
-n kube-system \
--set clusterName=my-k8s-cluser \
--set serviceAccount.create=true
```