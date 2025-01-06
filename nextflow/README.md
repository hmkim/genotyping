



# Custom AMI


## File

- ecs-optimized-ami.json

## Build using hashicorp packer

```
packer plugins install github.com/hashicorp/amazon
packer build ecs-optimized-ami.json
```

# Run

## Local

```
nextflow run main.nf --results_dir {local_result_directory} -profile standard
```

## AWS Batch

```
nextflow run main.nf -profile aws -with-report -resume -bucket-dir s3://{bucket_name}/gsa_analysis/result/
```
