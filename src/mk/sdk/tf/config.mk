
# --
# # Terraform
TERRAFORM_WORKSPACE?=$(PROJECT)-$(COMPONENT)-$(ENVIRONMENT)-$(DEPLOYMENT)

TF_CLI?=terraform
TF_FLAGS?=

## AWS-compatible endpoint URL propagated to Terraform and provider variables
TF_AWS_PROVIDER_URL?=$(AWS_PROVIDER_URL)

# --
# ## Overridable variables
TERRAFORM_INTERACTIVE?=true
TERRAFORM_S3_BUCKET_SUFFIX?=$(shell $(call cmd_sha256,$(AWS_ACCOUNT)-$(AWS_REGION)-salted) | cut -c1-8)
ifeq ($(origin TERRAFORM_S3_BUCKET_NAME), undefined)
TERRAFORM_S3_BUCKET_NAME:=sdk-terraform-state-$(TERRAFORM_S3_BUCKET_SUFFIX)
endif
TERRAFORM_DYNAMODB_NAME?=sdk-terraform-locking
TERRAFORM_DYNAMODB_ARN?=arn:aws:dynamodb:$(AWS_REGION):$(AWS_ACCOUNT):table/$(TERRAFORM_DYNAMODB_NAME)
TERRAFORM_DEPS?=

# --
# ## Standard variables
SOURCES_TF?=$(wildcard src/tf/*.tf src/tf/*/*.tf src/tf/*/*/*.tf)

# These are the Terraform configuration files to be imported in order
SOURCES_TFVARS?=\
	$(wildcard src/tf/variables.$(TENANCY).tfvars)\
	$(wildcard src/tf/variables.$(TENANCY).$(ENVIRONMENT).tfvars)\
	$(wildcard src/tf/variables.$(TENANCY).$(ENVIRONMENT).$(DEPLOYMENT).tfvars)

# We're copying the terraform source files as is (although we may lint/validate them first), then
# the IAC files, and then the modules as well
BUILD_TF?=\
	$(SOURCES_TF:src/tf/%=$(PATH_BUILD)/tf/%)\
	$(SOURCES_TFVARS:src/tf/%=$(PATH_BUILD)/tf/%)

RUN_TFVARS=$(if $(strip $(SOURCES_TFVARS)),$(PATH_RUN)/terraform/%/terraform.tfvars)
BUILD_ALL+=$(BUILD_TF)

# =============================================================================
#  UTILITY FUNCTIONS
# =============================================================================
# --
# `tf_cli(workspace,args)` runs terraform in the given workspace
tf_cli=env -C "$(abspath $(PATH_RUN)/terraform)/$1" SDK_PATH="$(abspath $(SDK_PATH))" AWS_ENDPOINT_URL="$(TF_AWS_PROVIDER_URL)" TF_VAR_aws_provider_url="$(TF_AWS_PROVIDER_URL)" $(TF_CLI) $2
tf_tag=echo "$(TIMESTAMP)" >> "$(abspath $(PATH_RUN)/terraform/$(if $1,$1,$*))/updated.log"

SHELL_EXPORTS+=\
	TERRAFORM_WORKSPACE\
	TERRAFORM_DYNAMODB_NAME\
	TERRAFORM_DYNAMODB_ARN\
	TERRAFORM_S3_BUCKET_NAME\
	TF_AWS_PROVIDER_URL

# EOF
