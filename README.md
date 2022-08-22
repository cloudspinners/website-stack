
# What website-stack is

This is a reference project for using cloudspin framework to build, deliver, and manage infrastructure. The infrastructure defined in this project is a simple implementation of static website hosting on an AWS S3 bucket. Also see [cloudspin.xyz](https://github.com/kief/website-cloudspin.xyz) as an example of a website that can be hosted on infrastructure provided by this stack.

website-stack is a plain Terraform code project that you could use by directly running the terraform command and passing parameters and configuration. However, it's designed to be used with [spin-tools](https://github.com/kief/spin-tools) to manage multiple instances of the infrastructure, including testing and delivery to different environments. spin-tools also supports assembling multiple infrastructure stacks into composable environments; however, this project is a single standalone stack.

spin-tools is packaged in a docker image using [dojo](https://github.com/kudulab/dojo), so that you can work with the code in projects like website-stack in a local working environment that has the necessary tooling (including things like Terraform and the aws CLI) prepackaged. This approach also ensures that the code can be used consistently in delivery pipelines.


# How-to guides

The following guides are needed:

- As an infrastructure developer, I want to work on the code for website-stack, so I can contribute changes to the project (and learn how to use the spin-tools)
- As an infrastructure user, I want to create and manage infrastructure using the website-stack code


## HOW TO: Prerequisites for the other how-tos.

1. Docker and docker-compose. I use colima to run it on my Mac. Make sure you're running it to expose network ports (with colima, start it with the command  `colima start --network-address`).
2. [Dojo](https://github.com/kudulab/dojo) (I install it on my Mac with homebrew)


## How to work on the code in this project

(Assumes you have commit access. Otherwise you can fork the repository, but we need instructions that don't require access to things like the AWS account and whatever else we use to test).

Run the `dojo` command, which downloads a [spin-tools](https://github.com/kief/spin-tools) container image and starts an instance for local development. This puts you at a prompt in the container, with the project files mounted. Write tests and code. When you're ready, push the code changes and the build job runs in github actions. This job will test and build the stack package so it can be made available for use.



The output of this project is a versioned website-stack package, which can be used to create instances of infrastructure for hosting static website content.


# How to create and manage infrastructure using the website-stack code

See [cloudspin.xyz](https://github.com/kief/website-cloudspin.xyz) for an example.

