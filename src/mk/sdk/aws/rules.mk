# -----------------------------------------------------------------------------
#
#  RULES
#
# -----------------------------------------------------------------------------

aws-shell: aws-shell@$(AWS_ROLE)-$(AWS_ACCOUNT)
	@

aws-shell@%: $(PATH_RUN)/bin/aws
	@AWS_ROLE=$(firstword $(subst -,$(SPACE),$*))
	AWS_ACCOUNT=$(lastword $(subst -,$(SPACE),$*))
	export AWS_ROLE
	export AWS_ACCOUNT
	export SHELL_PROMPT_NAME="AWS Shell [aws:$$AWS_ROLE@$$AWS_ACCOUNT $(call fmt_aws_account,$(lastword $(subst -,$(SPACE),$*)))]"
	$(call sh_aws_login,$(firstword $(subst -,$(SPACE),$*)),$(lastword $(subst -,$(SPACE),$*)))
	$(call shell_env,$(call shell_env,$(AWS_SHELL_EXPORTS) SHELL_PROMPT_NAME))


# --
# This retrieves the profile from the stem, gets the corresponding make/env
# var, and evaluates it to get the AWS profile name. The `aws` command is then
# run to configure the SSO, which then stores tokens in `~/.aws/sso/cache/`
aws-sso-auth--%: $(PATH_RUN)/bin/aws ## Configures AWS SSO for the given ROLE@ACCOUNT
	@export AWS_ROLE="$(call item_key,$*,@)"
	export AWS_ACCOUNT="$(call item_value,$*,,@)"
	export AWS_ACCOUNT_FMT="$(call fmt_aws_account,(call item_value,$*,,@))"
	export AWS_PROFILE_NAME="$$AWS_ROLE-$$AWS_ACCOUNT"
	if [ "$(AWS_AUTH_MODE)" != "sso" ]; then
		echo "$(call fmt_message,[AWS] Skipping SSO auth in mode $(BOLD)$(AWS_AUTH_MODE)$(RESET). Using static/local credentials.)"
		exit 0
	fi
	# We only configure if we need to (ie. the account doesn't exist).
	if [ ! -e "$(HOME)/.aws/config" ] || [ -z "$$(grep "profile $$AWS_PROFILE_NAME" < $(HOME)/.aws/config)" ]; then
		echo "$(call fmt_message,[AWS] Configuring profile $$AWS_PROFILE_NAME using role '$$AWS_ROLE' and account '$$AWS_ACCOUNT' $$AWS_ACCOUNT_FMT)"
		echo "$(call fmt_tip,Session name is $$AWS_PROFILE_NAME)"
		if [ -n "$(AWS_SSO_URL)" ]; then echo "$(call fmt_tip,SSO URL is $(AWS_SSO_URL))"; fi
		if [ -n "$(AWS_REGION)" ]; then echo "$(call fmt_tip,Region is $(AWS_REGION))"; fi
		$(AWS_CLI) configure sso --profile="$$AWS_PROFILE_NAME" --use-device-code --no-browser
	else
		echo "$(call fmt_message,[AWS] Using profile $$AWS_PROFILE_NAME using role '$$AWS_ROLE' and account '$$AWS_ACCOUNT' $$AWS_ACCOUNT_FMT)"
		$(AWS_CLI) sso login --profile="$$AWS_PROFILE_NAME" --use-device-code --no-browser
	fi


# -----------------------------------------------------------------------------
#
#  SUPPORTING RULES
#
# -----------------------------------------------------------------------------

$(PATH_RUN)/tmp/awscliv2.zip: $(call use_tool,curl) ## Downloads AWS CLI v2 installer
	@mkdir -p $(PATH_RUN)/tmp
	if curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$(PATH_RUN)/tmp/awscliv2.zip"; then
		echo "$(call fmt_result,[AWS] AWS CLI v2 installer downloaded successfully)"
	else
		echo "$(call fmt_error,[AWS] Could not download AWS CLI v2 installer)"
		rm -f "$@"
	fi

$(PATH_RUN)/bin/aws: $(PATH_RUN)/tmp/awscliv2.zip $(call use_tool,unzip mise) ## Installs AWS CLI
	@mkdir -p $(PATH_RUN)/tmp ; mkdir -p "$(PATH_RUN)/bin"
	if [ "$$(uname)" == "Darwin" ]; then
		if [ ! -e "/opt/homebrew/bin/aws" ]; then
			echo "--> On MacOS, you need to run: brew install awscli"
			exit 1
		else
			ln -sf /opt/homebrew/bin/aws "$@"
		fi
	else
		echo "$(call fmt_message,[AWS] Installing AWS CLI v2 into $(PATH_RUN))"
		# NOTE: We use -o to overwrite any existing installation, and -qq for quiet
		env -C "$(dir $<)" unzip -o -qq awscliv2.zip
		if env -C "$(dir $<)" ./aws/install $(if $(wildcard $(PATH_RUN)/share/aws-cli),--update) --bin-dir "$(abspath $(PATH_RUN)/bin)" --install-dir "$(abspath $(PATH_RUN)/share/aws-cli)"; then
			echo "$(call fmt_message,[AWS] AWS CLI installed successfully)"
			ln -sf "$(PATH_RUN)/share/aws-cli/v2/current/bin/aws_completer" "$(PATH_RUN)/bin/aws_completer"
			ln -sf "$(PATH_RUN)/share/aws-cli/v2/current/bin/aws" "$(PATH_RUN)/bin/aws"
			touch "$@"
		else
			echo "$(call fmt_error,[AWS] Could not install AWS CLI)"
			unlink "$@"
		fi
	fi

# EOF
