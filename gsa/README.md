
Download a program from site  and locate it in this folder.
- https://support.illumina.com/downloads/illumina-microarray-analytics-array-analysis-cli-v2-installers.html

# Env

```
export account_id={aws account id}
```

# ECR Creation

```
export repository_name=<repository name>
export aws_region=<aws region>
aws ecr create-repository --repository-name ${repository_name} --region ${aws_region}
```

# ECR Login

```
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${account_id}.dkr.ecr.${aws_region}.amazonaws.com
```


# Docker build

```
docker build -t illumina-array-analysis-cli .
```

# Docker tag

```
docker tag illumina-array-analysis-cli:latest ${account_id}.dkr.ecr.${aws_region}.amazonaws.com/illumina-array-analysis-cli:latest
```

# Docker push

```
docker push ${account_id}.dkr.ecr.${aws_region}.amazonaws.com/illumina-array-analysis-cli:latest
```
