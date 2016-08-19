# Amaysim Containerised PHP Application

## Preparation

Create a profile in ~/.aws/crentials

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

# Updates

Updating the stack.

	bundle exec sfn update amaysim-app --file cluster --defaults
