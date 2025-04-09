- AWS CLI
- Client the services ( RDS -> MYSQL CLIENT)
- For Go-Health App can binding to 80 port should be build to binary and execute with root user or sudo command
- ```sudo binaryfile &``` to background process

- When create the image from ec2 warning to reboot instance because the app can be shutdown

- About Name of Cluster and Type
- KMS EKS Should be Change and Enable it
- Dont forgot apply ingress aws load balancer
- [IRSA](https://dev.to/vinod827/secure-s3-access-for-aws-eks-pods-via-iam-role-2ena)


# Warning
- Launch Template should be generate from AMI , Dont try from instance

- The name of ingress should be different

- Pod have access The s3 can work with session token with command 
```bash 
    aws sts get-session-token--duration-seconds 3600
```
- Install aws load balancer eks with command

### Add EKS Repository Helm
```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
-n kube-system \
--set clusterName=my-k8s-cluser \
--set serviceAccount.create=true
```

- Create Ingress Class with command 
```bash
kubectl apply -f ./practice2025/eks/k8s/ingress-alb-class.yml 
```
# Security Group
- Security Group for RDS and Elasticache

RDS-NODE-ACCESS-SG:

    INBOUND-ROLES:
        -
    OUTBOUND-ROLES:
        - anywhere
Attach to EC2 EKS NODES

RDS-SG:

    INBOUND-ROLES:
        - MySQL/Aurora -> RDS-NODE-ACCESS
    OUTBOUND-ROLES:
        - anywhere
Attach to RDS Service

ELC-NODE-ACCESS-SG:

    INBOUND-ROLES:
        -
    OUTBOUND-ROLES:
        - anywhere
Attach to EC2 EKS NODES

ELC-SG:

    INBOUND-ROLES:
        - TCP 6379 -> ELC-NODE-ACCESS-SG
    OUTBOUND-ROLES:
        - anywhere    
Attach to Elasticache Service

# IAM

Policy Minimal For EKS Question LKS:

    - AmazonEC2ContainerRegistryFullAccess 
    - AmazonS3FullAccess
    - AmazonEC2FullAccess 
    - AmazonRDSFullAccess
    - IAMFullAccess 
    - AmazonElastiCacheFullAccess 
    - AmazonVPCFullAccess 
    - AWSCloudFormationFullAccess 
    - EksFullAccess (Custom)
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "eks:*",
            "Resource": "*"
        },
        {
            "Action": [
                "ssm:GetParameter",
                "ssm:GetParameters"
            ],
            "Resource": [
                "arn:aws:ssm:*:277789128961:parameter/aws/*",
                "arn:aws:ssm:*::parameter/aws/*"
            ],
            "Effect": "Allow"
        },
        {
             "Action": [
               "kms:CreateGrant",
               "kms:DescribeKey"
             ],
             "Resource": "*",
             "Effect": "Allow"
        },
        {
             "Action": [
               "logs:PutRetentionPolicy"
             ],
             "Resource": "*",
             "Effect": "Allow"
        }        
    ]
}
```
    - AWSKeyManagementServicePowerUser

Roles for AWS Services:

    - FrontEnd(NodeJS)
        - AmazonS3FullAccess
    
    - BackEnd(Golang)
        - AmazonRDSFullAccess
        - AmazonElastiCacheFullAccess


### Policy AWS ALB
```bash
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json


# Requirement account have iam policy full access
aws iam create-policy \
--policy-name AWSLoadBalancerControllerIAMPolicy \
--policy-document file://policy/iam_policy.json
```


# WORKFLOW EXECUTION LKS Question 

## EKS (Production)

1. Create Custom KMS for EKS
2. Create Access Key and Login AWS CLI -> Create Cluster by eksctl 
3. While waiting for the finished cluster EKS do Create
    - Security Group(RDS,Elasticache)
        -> RDS(attach the SG) 
        -> Elasticache(attach the SG)
    - S3 
    - ECR(Front End and Back End) 
        -> Build Application (Front End and Back End) 
            -> re tag the image to ECR image and Push Image Result re tag ECR
4. Configuration the App 

## Autoscalling Based (Development)
1. VPC (Single NAT and S3 Endpoint)
2. Roles (Front End and Back End)
3. Security Group
   - ELB (Front End and Back End)
   - SSH
   - APP (Front End and Back End)
   - RDS (Back End)
   - Elastic Cache (Back End)
4. Elastic Cache (t4g.micro)
5. RDS (Free tier)
6. S3 With Policies GetObject and PutObject and Resource bucket-name/*
7. EC2 (SSH,Front End and Back End) And Installing Application with Try successfully or failed and debugging if failed
8. Target Groups (Front End and Back End)
9. ELB (Front End and Back End)
10. Try ELB 
11. AMI (Front End and Back End)
12. Launch Template
13. Autoscalling with polices cpu utilization



# Solving Error Exec Binary

EC2 Instance Type with end g or AWS Graviton CPU is architecthure ARM and without g is architecture AMD
```bash
# For multi archi docker registry
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t tirtahakimpambudhi/nodejs-s3-appv3:multiarch \
  --push \
  .
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t tirtahakimpambudhi/go-health:multiarch \
  --push \
  .
# Specific
docker buildx build \
  --platform linux/arm64 \
  -t tirtahakimpambudhi/go-health:arm \
  --push \
  .
  
docker buildx build \
  --platform linux/amd64 \
  -t tirtahakimpambudhi/go-health:amd \
  --push \
  .
```

Check the App with command 
```
curl -s -w "\nHTTP Status: %{http_code}\n" http://example.com
```