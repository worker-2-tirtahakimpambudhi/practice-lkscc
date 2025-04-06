## ECR (Elastic Container Registry)
### Example

REGION: us-east-1

USERNAME: AWS

ACCOUNT ID: 705368130152

REPOSITORY: $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:latest

----
## RDS (RELATIONAL DATABASE SERVICE)
### Example

USERNAME: TirtaHakimP35

PASSWORD: TirtaHakimP35

NAME: laravel

ENDPOINT: 

## ECS (Elastic Container Service)

### WORDPRESS OFFICIAL ENVIRONMENT
---
WORDPRESS_DB_HOST=

WORDPRESS_DB_USER=

WORDPRESS_DB_PASSWORD=

WORDPRESS_DB_NAME=

### BITNAMI/WORDPRESS ENVIRONMENT
---
WORDPRESS_DATABASE_HOST=

WORDPRESS_DATABASE_USER=

WORDPRESS_DATABASE_PASSWORD=

WORDPRESS_DATABASE_NAME=

#### WARNING 
Cannot Try Deploy Task Definition With Same Again Because the File in Elastic Filesystem Service Can't Replace

## S3 (Simple Service Storage)
### Example
----
Bucket Name: bucket-tirtahakimp35

Folder Name Wordpress: wp-content

Folder Name Laravel App: files

### Policy S3 For Publish Object
```yaml
wp-content/*
```

## EFS (Elastic Filesystem Service) 

FS-ID: fs-XXXX

## ELASTIC CACHE

ENDPOINT: tls://

## SQS

NAME: laravel-queue

URL: 

## KMS (Key Management Service)

AWS Service Use KMS For Encryption -> (RDS,ECR,ECS,S3,ELASTICACHE,EFS,EKS)

## ELB (Elastic Load Balance)

### Setting Wordpress Container Warning
- SSL with Self-Signate,
- Load Balance Register Listener Port 443 to 80 and Change Security Group to ELB-SG
- Load Balance Target Group - Change The Health Check Setting



## CREDENTIALS 
---
AWS CREDENTIALS LOCATION IN ``` ~/.aws/credentials ```
```
[default]
aws_access_key_id=
aws_secret_access_key=
aws_session_token=
```

## WARNING 
- THE EBS Encryption cannot attach to KMS CMK 

## WARNING FOR LKS LARAVEL APP
- Mount EFS
- change redis default and cache config add the scheme to tls
- dont forgot change region
- dont forgot change session token in config with key token in s3 and sqs
- dont forgot key:generate
- dont forgot migrate the db
- dont forgot change permission on folder public with -R
- if the load balancer success create auto scaling with EXISTING load balancer
- dont forgot change permission for storage dir is www-data midification permission 777 with argument -R mean recursively
- dont forgot change permission for bootstrap dir is www-data midification permission 777 with argument -R mean recursively
- dont forgot change permission for public dir is www-data midification permission 755 with argument -R mean recursively
- dont forgot add scheme redis

