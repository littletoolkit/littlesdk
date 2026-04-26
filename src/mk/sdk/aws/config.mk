
## AWS SSO tenancy used to derive `AWS_SSO_URL` when `AWS_AUTH_MODE=sso`
AWS_SSO_TENANCY?=
AWS_SSO_URL=$(if $(strip $(AWS_SSO_TENANCY)),https://$(AWS_SSO_TENANCY).awsapps.com/start/#/,$(error "AWS_SSO_TENANCY is required when using AWS SSO"))

## Path to the AWS CLI binary managed by the SDK
AWS_CLI=$(PATH_RUN)/bin/aws

## Base endpoint URL for AWS-compatible providers (for example LocalStack/Floci)
AWS_PROVIDER_URL?=

## Authentication mode: `sso` (real AWS) or `static` (local/emulated)
AWS_AUTH_MODE?=$(if $(strip $(AWS_PROVIDER_URL)),static,sso)

## Static access key used when `AWS_AUTH_MODE!=sso`
AWS_ACCESS_KEY_ID?=test
## Static secret key used when `AWS_AUTH_MODE!=sso`
AWS_SECRET_ACCESS_KEY?=test
## Optional static session token used when `AWS_AUTH_MODE!=sso`
AWS_SESSION_TOKEN?=

# Defaults
AWS_DEFAULT_ROLE?=DeploymentAccess
AWS_DEFAULT_REGION?=ap-southeast-2
AWS_DEFAULT_ACCOUNT?=

# Environment variaables, in the format AWS_ENV_<tenancy>_<environment>?=<account>:<region>:<role>
AWS_ENV_default_local?=000000000000:$(AWS_DEFAULT_REGION):$(AWS_DEFAULT_ROLE)

AWS_ACCOUNT=$(call aws_account,$(TENANCY),$(ENVIRONMENT))
AWS_ROLE=$(call aws_role,$(TENANCY),$(ENVIRONMENT))
AWS_REGION=$(call aws_region,$(TENANCY),$(ENVIRONMENT))

fmt_aws_account=$(call aws_account_icon,$1) $(call aws_account_tenant,$1)-$(call aws_account_environment,$1)

# --
# aws_account(tenancy,environment)
# Returns the AWS account for the given tenancy and environment.
aws_account=$(call get_ensure,$(call get_nth,1,$(AWS_ENV_$1_$2)),AWS_ENV_$1_$2)

# --
# aws_region(tenancy,environment)
# Returns the AWS region for the given tenancy and environment.
aws_region=$(call get_ensure,$(call get_nth,2,$(AWS_ENV_$1_$2)),AWS_ENV_$1_$2)

# --
# aws_role(tenancy,environment)
# Returns the AWS role for the given tenancy and environment.
aws_role=$(call get_ensure,$(call get_nth,3,$(AWS_ENV_$1_$2)),AWS_ENV_$1_$2)

# ACCOUNT:REGION:ROLE:TENANCY:ENVIRONMENT
# 557690594731:ap-southeast-2:DeploymentAccess:financialplatforms:development
aws_account_vars=$(filter AWS_ENV_%,$(filter-out AWS_ENV_DEFAULT AWS_ENV_CONTROL,$(.VARIABLES)))
aws_account_list=$(foreach V,$(call aws_account_vars),$(subst AWS:ENV:,,$(subst _,:,$($V):$V)))
aws_account_fields=$(subst :,$(SPACE),$(if $(filter $(1):%:$(TENANCY):$(ENVIRONMENT),$(call aws_account_list)),$(filter $(1):%:$(TENANCY):$(ENVIRONMENT),$(call aws_account_list)),$(filter $(1)%,$(call aws_account_list))))
aws_account_region=$(word 2,$(call aws_account_fields,$1))
aws_account_role=$(word 3,$(call aws_account_fields,$1))
aws_account_tenant=$(word 4,$(call aws_account_fields,$1))
aws_account_environment=$(word 5,$(call aws_account_fields,$1))
aws_account_icon=$(call fmt_icon,$(call aws_account_environment,$1))

define sh_aws_login
	# Set the desired AWS account ID and profile name
	unset AWS_ACCESS_KEY_ID
	unset AWS_SECRET_ACCESS_KEY
	unset AWS_SESSION_TOKEN
	if [ "$(AWS_AUTH_MODE)" != "sso" ]; then
		export AWS_ROLE="$1"
		export AWS_ACCOUNT="$2"
		export AWS_PROFILE_NAME="$$AWS_ROLE-$$AWS_ACCOUNT"
		export AWS_REGION="$(AWS_REGION)"
		export AWS_ACCESS_KEY_ID="$(AWS_ACCESS_KEY_ID)"
		export AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)"
		export AWS_SESSION_TOKEN="$(AWS_SESSION_TOKEN)"
		export AWS_ENDPOINT_URL="$(AWS_PROVIDER_URL)"
		echo "$(call fmt_message,[AWS] Using local/static AWS credentials mode=$(BOLD)$(AWS_AUTH_MODE)$(RESET) account=$(BOLD)$$AWS_ACCOUNT$(RESET) endpoint=$(BOLD)$${AWS_ENDPOINT_URL:-<none>}$(RESET))"
		exit 0
	fi
	if [ -z "$1" ]; then echo "$(call fmt_error,[AWS] Missing role name in call to (sh_aws_login role=$1 account=$2))"; exit 1; fi
	if [ -z "$2" ]; then echo "$(call fmt_error,[AWS] Missing account name in call to (sh_aws_login role=$1 account=$2))"; exit 1; fi
	if [[ ! "$1" =~ ^([A-Z][a-z]+)+$$ ]]; then
		echo "$(call fmt_error,[AWS] Role name should be like RoleName$(COMMA) got: $(BOLD)$(1))"; exit 1
	fi
	if [[ ! "$2" =~ ^[0-9]+$$ ]]; then
		echo "$(call fmt_error,[AWS] Account should be like 000000000000$(COMMA) got: $(BOLD)$(1))"; exit 1
	fi;
	echo "$(call fmt_message,[AWS] Logging into AWS role=$(BOLD)$1$(RESET) account=$(BOLD)$2$(RESET) $(call fmt_aws_account,$2))"
	AWS_SSO_ACCOUNT_ID="$2";
	AWS_SSO_ROLE_NAME="$1";
	if [ -d "$(HOME)/.aws/sso/cache" ]; then
		# FIXME: Here we rely on a file named like `botocore-client-id-ap-southeast-2.json` to extract
		# the credentials. This should be created by the `configure sso --profile` command, but it seems
		# that sometimes that file does not exist.
		AWS_SSO_CACHE="$$(grep accessToken $(HOME)/.aws/sso/cache/*.json | cut -d: -f1 | head -n1)"
	else
		AWS_SSO_CACHE=""
	fi
	# We look for the SSO cache
	# We export the AWS ACCOUNT and REGION
	export AWS_ROLE=$$AWS_SSO_ROLE_NAME
	export AWS_ACCOUNT=$$AWS_SSO_ACCOUNT_ID
	export AWS_PROFILE_NAME=$$AWS_ROLE-$$AWS_ACCOUNT
	export AWS_REGION=$(AWS_REGION)
	if [ -f "$$AWS_SSO_CACHE" ]; then
		# FIXME: There are sometimes decoding errors there
		AWS_SSO_TOKEN="$$($(PYTHON) -c "import json;print(json.load(open('$$AWS_SSO_CACHE','rt'))['accessToken'])")";
	else
		echo "$(call fmt_error,[AWS] Could not find SSO cache file $$AWS_SSO_CACHE $(BOLD)$$AWS_PROFILE_NAME)"
		echo "$(call fmt_tip,To re-authorise$(COMMA) run: '$(BOLD)$(call fmt_makecmd,aws-sso-auth--$$AWS_ROLE@$$AWS_ACCOUNT)')"
		exit 1
	fi
	AWS_CREDENTIALS_CMD="$(AWS_CLI) sso get-role-credentials --account-id "$$AWS_SSO_ACCOUNT_ID" --role-name "$$AWS_SSO_ROLE_NAME" --access-token "$$AWS_SSO_TOKEN" --region $(AWS_REGION)"
	export AWS_CREDENTIALS="$$($$AWS_CREDENTIALS_CMD)"
	if [ -z "$$AWS_CREDENTIALS" ]; then
		# NOTE: If we get 'An error occurred (UnauthorizedException) when calling
		# the GetRoleCredentials operation: Session token not found or invalid ┄
		# this means that we need to clear ~/.aws/sso
		echo "$(call fmt_error,[AWS] Invalid credentials for $$AWS_PROFILE_NAME)"
		echo "$(call fmt_message,[AWS] Using credentials at $$AWS_SSO_CACHE)"
		echo "$(call fmt_message,[AWS] $$(echo -n "$$AWS_CREDENTIALS_CMD" | sed "s|$$AWS_SSO_TOKEN|▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒|g"))"
		echo "$(call fmt_tip,To re-authorise$(COMMA) run: '$(BOLD)$(call fmt_makecmd,aws-sso-auth--$1@$2)')"
		exit 1
	fi
	eval "$$($(PYTHON) -c "import os,json,datetime;d=json.loads(os.environ['AWS_CREDENTIALS'])['roleCredentials'];k0='accessKeyId';k1='secretAccessKey';k2='sessionToken';k3='expiration';print(f'export AWS_ACCESS_KEY_ID={d[k0]}\nexport AWS_SECRET_ACCESS_KEY={d[k1]}\nexport AWS_SESSION_TOKEN={d[k2]}\nexport AWS_SESSION_EXPIRATION={datetime.datetime.fromtimestamp(d[k3]/1000).isoformat()}')")"
	echo "$(call fmt_message,[AWS] Credentials expire at: $$AWS_SESSION_EXPIRATION)"
endef

CLEAN_ALL+=$(PATH_RUN)/bin/aws $(PATH_RUN)/tmp/awscliv2.zip $(PATH_RUN)/share/aws-cli

AWS_SHELL_EXPORTS+=\
	AWS_ACCESS_KEY_ID\
	AWS_ACCOUNT\
	AWS_CREDENTIALS\
	AWS_ENDPOINT_URL\
	AWS_PROVIDER_URL\
	AWS_AUTH_MODE\
	AWS_PROFILE_NAME\
	AWS_REGION\
	AWS_ROLE\
	AWS_SECRET_ACCESS_KEY\
	AWS_SESSION_EXPIRATION\
	AWS_SESSION_TOKEN

# EOF
