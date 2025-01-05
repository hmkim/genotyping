
# Env

```
account_id = <aws account id>
```

# ECR Creation

```
export repository_name=<repository name>
export aws_region=<aws region>
aws ecr create-repository --repository-name ${repository_name} --region ${aws_region}
```

# ECR Login

```
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${account_id}.dkr.ecr.ap-northeast-2.amazonaws.com
```


# Docker build

```
docker build -t plink .
```

# Docker tag

```
docker tag plink:latest ${account_id}.dkr.ecr.ap-northeast-2.amazonaws.com/plink:latest
```

# Docker push

```
docker push ${account_id}.dkr.ecr.${aws_region}.amazonaws.com/plink:latest
```
