# Amaysim Containerised PHP Application

## Preparation

Create a profile in ~/.aws/credentials

	[amaysim]
	region = ap-southeast-2
	aws_access_key_id = changeme
	aws_secret_access_key = changeme

Export the profile name

	export AWS_PROFILE_NAME=amaysim

Make sure Ruby and Bundler is installed.

	bundle install

## Creation

Creating the stack.

	bundle exec sfn create amaysim-app --file cluster

## Updates

Updating the stack.

	bundle exec sfn update amaysim-app --file cluster --defaults

## Development

Docker Compose support is provided to allow the application to run locally.

        docker-compose build
        docker-compose up

Removal of the application is as follows.

	docker-compose down -v

## Deployments

Deployments are as simple as destroying the instances and letting the auto scaling group recreate them.

The code pipeline is setup that all pushes to the master branch automatically cause Docker Hub to build a new image. Instances automatically pull the latest image therefore deploying the latest code.
