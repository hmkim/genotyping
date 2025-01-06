# genotyping

1. prepare the docker containers and push them on Amazon ECR.

2. I recommend testing it in local mode first.

3. You can then use AWS Batch to create Queue and CE, set their contents in nextflow.config, and run in batch.
