
# What

This is a reference project for using cloudspin tools to build an infrastructure stack. The infrastructure is a simple implementation of website hosting on an AWS S3 bucket.

This is a plain Terraform code project that you could use by running the terraform command and passing parameters and configuration. However, it's designed to be used with spin-tools to manage multiple instances of the infrastructure, including testing and delivery to different environments. spin-tools also support assembling multiple infrastructure stacks into composable environments; however, this project is a single standalone stack.

This project also uses Dojo (see below) to provide a consistent local development environment.


# How to work with this project

Prerequisites:

1. Docker (I use colima to install it on my Mac)
2. [Dojo](https://github.com/kudulab/dojo) (I install it on my Mac with homebrew)

Run `dojo` to download a spin-tools container image and start an instance for local development. This puts you at a prompt in the container, with your project files mounted. Write tests and code. When you're ready, push the code changes and the CI job runs in github actions. This job will test and build the stack project artefact so it can be delivered to environments that use it.
