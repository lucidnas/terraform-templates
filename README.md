


# App Infrastructure

### Architecture Principle
Over the years, I've come to embrace the principle of [separation of concerns](https://www.castsoftware.com/blog/how-to-implement-design-pattern-separation-of-concerns) and I've found decoupling cloud resources into separate templates to be the most effective way I manage and organize cloud resources, especially those of different types. 

Of course, there are scenarios where it makes sense to group cloud resources together in one huge template but my preference will always be to decouple first and couple later if the scenario calls for that.


In the spirit of seperation of concerns, I have placed each resource in their respective terraform template within the `app-infrastructure` folder.

Below is a summary of what each terraform template is provisioning. There are additional comments added in each template explaining why some properties were selected for a specific resource.


### variables.tf
Declares common variables (such as name, region etc) that are referenced in other templates.
- This is where I learnt about variables in terraform.

### main.tf
Declares the terraform and aws provider configuration.

### s3.tf
Defines a private s3 bucket with versioning and S3 Server Side Encryption enabled. Public Access is also denied. 

### vpc.tf
Defines a VPC with both public and private subnets. Tags the VPC and subnets. 
- I used the vpc module which is quite useful as it takes care of a bunch of other resources and operations such as subnets, nat gateway, internet gateways, attachment and tagging of these resources.
- This is where I learnt about terraform modules, data sources which are all pretty cool concepts.

### ecs.tf
Defines an ECS cluster, a task definition, and a service.

Lastly, this is my first time playing with Terraform and I must say it was quite easy to get resources provisioned. Documentation also helped me a lot. I work mainly with cloudformation so overall, this has been a breath of fresh air.


## Deploying the resources

- unzip `app-infra.zip` or `git clone https://github.com/lucidnas/terraform-templates.git` and cd into the folder.
- run `terraform apply -var name=your-app-name` and accept deployment prompt.







