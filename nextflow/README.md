



# Custom AMI


## File

- ecs-optimized-ami.json

## Build using hashicorp packer

```
packer plugins install github.com/hashicorp/amazon
packer build ecs-optimized-ami.json
```
