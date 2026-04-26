# -----------------------------------------------------------------------------
#
#  TERRAFORM
#
# -----------------------------------------------------------------------------

# --
#  `tf_prep(workspace)` ensuress that the given terraform workspace exists
#  and is initialized with the current aws role and account.
define tf_prep
	$(call sh_aws_login,$(AWS_ROLE),$(AWS_ACCOUNT))
	if [ ! -e "$(PATH_RUN)/terraform/$1" ]; then
		echo "$(call fmt_error,[TFM] Missing Terraform workspace: $1)"
		echo "$(call fmt_tip,Run 'make tf-init-$1')"
		exit 1
	fi

endef



# `tf_run(workspace,args,redirect?)`, a combination of `tf_prep` and `tf_cli`
# that will detect failures and log errors in a log file.
define tf_run
	$(call tf_prep,$1)
	echo "$(call fmt_message,[TFM] Running '$(strip terraform $2)' in: $(call fmt_path,$(PATH_RUN)/terraform/$1))"
	date_part=$$(date +%Y%d%m%H%M%S)
	# We clean up the logs that are too old
	mkdir -p "$(PATH_RUN)/log"
	find "$(PATH_RUN)/log" -type f -name "*.log" -mtime +14 -delete
	TERRAFORM_OUTPUT=$(PATH_RUN)/log/terraform-$$(date +%Y%d%m%H%M%S)_$$((RANDOM % 1000)).log
	# We add the project bin and src/sh to PATH, so that the scripts can be run
	PATH=$(abspath $(PATH_RUN)/bin):$(abspath bin):$(abspath src/sh):$(PATH)
	export PATH
	if [ -n "$${TERRAFORM_OUTPUT:-}" ]; then
		mkdir -p "$$(dirname "$$TERRAFORM_OUTPUT")"
		echo "$(call fmt_message,[TFM] Logging terraform output: $(call fmt_path,$$TERRAFORM_OUTPUT))"
		# We disable and re-enable the pipefail
		set +o pipefail
		$(call tf_cli,$1,$2) 2>&1 | tee "$$TERRAFORM_OUTPUT" $3
		set -o pipefail
		# We intercept errors and give useful error messages
		if grep -q 'Error:' "$$TERRAFORM_OUTPUT"; then
			if grep -q 'Inconsistent dependency lock file' "$$TERRAFORM_OUTPUT"; then
				echo "$(call fmt_tip,Reinit Terraform: '$(call fmt_makecmd,tf-reinit@$1)' )"
			elif grep -q 'Error acquiring the state lock' "$$TERRAFORM_OUTPUT"; then
				echo "$(call fmt_tip,Reinit Terraform: '$(call fmt_makecmd,tf-unlock@$1 ARGS=$$(grep "ID:" $$TERRAFORM_OUTPUT | tail -n1 | sed 's| ||g' | cut -d: -f2 ))' to unlock the state)"
			# Detect backend init errors and attempt automatic reinitialization + retry
			elif grep -q -i 'Backend initialization required' "$$TERRAFORM_OUTPUT" || grep -q -i 'Please run "terraform init"' "$$TERRAFORM_OUTPUT" || grep -q -i 'Initial configuration of the requested backend' "$$TERRAFORM_OUTPUT"; then
				echo "$(call fmt_message,[TFM] Terraform backend appears uninitialized — attempting automatic reinitialization for workspace $1)"
# Attempt to reinitialize the workspace using existing make target
# Forward user make variable overrides via $(MAKEOVERRIDES) so things like ENVIRONMENT=production are preserved
if $(SDK_MAKE) $(MAKEOVERRIDES) tf-reinit@$1; then
					# Reinitialization succeeded — retry previous terraform command
					echo "$(call fmt_message,[TFM] Reinitialization succeeded — retrying previous terraform command)"
					set +o pipefail
					$(call tf_cli,$1,$2) 2>&1 | tee -a "$$TERRAFORM_OUTPUT"
					set -o pipefail
					# If there are still errors after retry, print a helpful tip
					if grep -q 'Error:' "$$TERRAFORM_OUTPUT"; then
						echo "$(call fmt_tip,If the problem persists run: '$(call fmt_makecmd,tf-reinit@$1)' and inspect the logs in $(PATH_RUN)/log/terraform-*.log')"
						exit 1
					fi
				else
					echo "$(call fmt_tip,Reinit failed: run '$(call fmt_makecmd,tf-reinit@$1)' and inspect the logs)"
					exit 1
				fi
			fi
			exit 1
		fi
	else
		if ! $(call tf_cli,$1,$2) $3; then
			exit 1
		fi
	fi
endef

# =============================================================================
# INIT
# =============================================================================

.PHONY: tf-init
tf-init: tf-init@$(TERRAFORM_WORKSPACE) ## Initializes a Terraform workspace
	@

.PHONY: td-init@%
tf-init@%: tf-workspace@% ## Initializes the given workspace (support TF_FLAGS=…)
	@$(call tf_run,$*,init $(if $(TF_FLAGS),$(TF_FLAGS),-migrate-state))

# =============================================================================
# UNLOCK
# =============================================================================

.PHONY: tf-unlock
tf-unlock: tf-unlock@$(TERRAFORM_WORKSPACE)
	@

.PHONY: td-unlock@%
tf-unlock@%: tf-workspace@% ## Unlocks the given workspace with ARGS="lock-id"
	@$(call tf_run,$*,force-unlock $(ARGS))

# =============================================================================
# CLEAN
# =============================================================================

.PHONY: tf-clean
tf-clean: tf-clean@$(TERRAFORM_WORKSPACE) ## Cleans a Terraform workspace
	@

tf-clean@%: ## Cleans the Terrafor workspace
	@
	if [ -e "$(PATH_RUN)/terraform/$*" ]; then
		echo "$(call fmt_message,[TFM] Cleaning up Terraform workspace: $*)"
		for FILE in $$(echo $(PATH_RUN)/terraform/$*/*.task); do
			echo "$(call fmt_message,[TFM] Removing task file $$FILE)"
			unlink $$FILE
		done
	fi

# =============================================================================
# REINIT
# =============================================================================

.PHONY: tf-reinit
tf-reinit: tf-reinit@$(TERRAFORM_WORKSPACE) ## Reinitializes a Terraform workspace
	@

tf-reinit@%: ## Initializes the given workspace
	@$(call tf_run,$*,init $(if $(TF_FLAGS),$(TF_FLAGS),-migrate-state -backend-config=$(abspath $(PATH_RUN)/terraform/$*/backend.hcl)))

# =============================================================================
# IMPORT
# =============================================================================

.PHONY: tf-import
tf-import: tf-import@$(TERRAFORM_WORKSPACE) ## Imports the resources defined in TF_IMPORT="type.name=name+…"
	@

# NOTE: This is a useful thing to do when you want to import existing resources
# into the terraform state.
tf-import@%: tf-workspace@% ## Imports the resources defined in ARGS="type.name=name+…"
	@
	IMPORTS="$(subst :,=,$(subst $(COMMA),$(SPACE),$(subst +,$(SPACE),$(ARGS))))"
	if [ -z "$$IMPORTS" ]; then
		echo "$(call fmt_error,[TFM] Missing argument in $@: ARGS=type:resource$(COMMA)type:resource$(COMMA)…)"
		exit 1
	fi
	echo "$(call fmt_message,[TFM] Importing resource: $$IMPORTS)"
	$(call sh_aws_login,$(AWS_ROLE),$(AWS_ACCOUNT))
	for RESOURCE in $$IMPORTS; do
		$(call tf_run,$*,import $${RESOURCE%%=*} $${RESOURCE##*=})
	done

# =============================================================================
# WORKSPACE
# =============================================================================

.PHONY: tf-workspace ## Shows the details for the default workspace
tf-workspace: tf-workspace@$(TERRAFORM_WORKSPACE) ## Initializes TERRAFORM_WORKSPACE
	@

.PHONY: tf-workspace@% ## Shows the details of the given workspace
tf-workspace@%: $(PATH_RUN)/terraform/%/workspace-init.task $(PATH_RUN)/terraform/%/workspace-files.task $(PATH_RUN)/terraform/%/updated.log ## Initializes the given workspace
	@echo "$(call fmt_message,[TFM] Terraform workspace at: $(call fmt_path,$<))"

# =============================================================================
# PLAN
# =============================================================================

tf-plan: tf-plan@$(TERRAFORM_WORKSPACE) ## Shows planned changes for the default workspace
	@

# FIXME: Not sure why but on the first run, we need to run tf-init first.
tf-plan@%: tf-workspace@% $(SOURCES_TF) $(SOURCES_TFVARS) $(RUN_TFVARS) ##  Shows planned changes for the given workspace
	@
	$(call sh_aws_login,$(AWS_ROLE),$(AWS_ACCOUNT))
	VARFILES="$(foreach P,$(filter %.tfvars,$^),$(abspath $P))"
	for VARFILE in $$VARFILES; do
		echo "$(call fmt_message,[TFM] Using Terraform variables at: $(call fmt_path,$$VARFILE))"
		if [ ! -e "$$VARFILE" ]; then
			echo "$(call fmt_error,[TFM] Missing Terraform variables file: $$VARFILE)"
			echo "$(call fmt_tip,Run '$(call fmt_makecmd,tf-workspace@$*)')"
			exit 1
		fi
	done
	$(call tf_run,$*,plan $(foreach P,$(filter %.tfvars,$^),-var-file="$(abspath $P)") -input=false $(TF_FLAGS) $(if $(call is_true,$(TERRAFORM_INTERACTIVE)),,-auto-approve))
	if [ $$? -ne 0 ]; then
		echo "$(call fmt_message,[TFM] Workspace may need to be reinitialised)"
		echo "$(call fmt_tip,Run '$(call fmt_makecmd,tf-reinit@$*)')"
		exit 1
	fi

# =============================================================================
# APPLY
# =============================================================================

tf-apply: tf-apply@$(TERRAFORM_WORKSPACE) ## Applies the planned changes to the default workspace
	@

tf-apply@%: tf-workspace@% $(SOURCES_TF) $(SOURCES_TFVARS) $(RUN_TFVARS) ##  Applies the planned changes to the workspace
	@
	VARFILES="$(foreach P,$(filter %.tfvars,$^),$(abspath $P))"
	for VARFILE in $$VARFILES; do
		echo "$(call fmt_message,[TFM] Using Terraform variables at: $(call fmt_path,$$VARFILE))"
	done
	$(call tf_run,$*,apply $(foreach P,$(filter %.tfvars,$^),-var-file="$(abspath $P)") -input=false $(TF_FLAGS) $(if $(call is_true,$(TERRAFORM_INTERACTIVE)),,-auto-approve))
	if [ $$? -ne 0 ]; then
		echo "$(call fmt_message,[TFM] Workspace may need to be reinitialised)"
		echo "$(call fmt_tip,Run '$(call fmt_makecmd,tf-reinit@$*)')"
		exit 1
	else
		$(call tf_tag)
	fi

# =============================================================================
# OUTPUT
# =============================================================================

tf-output: tf-output@$(TERRAFORM_WORKSPACE)
	@

tf-output@%: $(PATH_RUN)/terraform/%/outputs.json $(PATH_RUN)/terraform/%/outputs.sh
	@
	echo "$(call fmt_message,[TFM] Terraform outputs for workspace: $(foreach P,$^,$(call fmt_path,$P)))"
	cat "$<"

# =============================================================================
# FORMATTING & LINTING
# =============================================================================

.PHONY: tf-lint  ## Lints the terraform sources
tf-lint: $(PATH_RUN_TASK)/tf-lint.task
	@

$(PATH_RUN_TASK)/tf-lint.task: $(SOURCES_TF)
	@
	mkdir -p "$(dir $@)" ; date > "$@"
	$(call tf_run,$*,fmt -check -recursive $(SOURCES_TF)) | tee "$@"

.PHONY: tf-fmt
tf-fmt: $(PATH_RUN_TASK)/tf-fmt.task ## Formats the terraform sources
	@

tf-fmt:
$(PATH_RUN_TASK)/tf-fmt.task: $(SOURCES_TF)
	mkdir -p "$(dir $@)" ; date > "$@"
	@$(call tf_run,$*,fmt -recursive $(SOURCES_TF)) | tee "$@"

# =============================================================================
# DESTROY
# =============================================================================

tf-destroy-plan: tf-destroy-plan@$(TERRAFORM_WORKSPACE) ## Shows plan for deprovisioning Terraform resources
	@

tf-destroy-plan@%: tf-destroy-plan@% ##  … for the given workspace
	@$(call tf_run,$*,plan -input=false -destroy$(if $(call is_true,$(TERRAFORM_INTERACTIVE)),,-auto-approve))

tf-destroy: tf-destroy@$(TERRAFORM_WORKSPACE) ## Deprovisioning Terraform resources
	@

tf-destroy@%: tf-workspace@% ##  … for the given worksace
	@$(call tf_run,$*,apply -destroy$(if $(call is_true,$(TERRAFORM_INTERACTIVE)),,-auto-approve -input=false) $(TF_FLAGS))

# =============================================================================
# REFRESH
# =============================================================================

tf-refresh: tf-refresh@$(TERRAFORM_WORKSPACE) ## Refreshes the default Terraform workspace
	@

tf-refresh@%: tf-workspace@% ## Refreshes the given Terraform worksace
	@$(call tf_run,$*,refresh)

# =============================================================================
# LIST
# =============================================================================

tf-list: tf-list@$(TERRAFORM_WORKSPACE) ## Lists the resources in the default Terraform workspace
	@

tf-list@%: tf-workspace@% ## List the resources in the given Terraform workspace
	@$(call tf_run,$*,state list)

# =============================================================================
# TF SCHEMA
# =============================================================================

tf-schema: tf-schema@$(TERRAFORM_WORKSPACE) ## Lists the resources in the default Terraform workspace
	@

tf-schema@%: $(PATH_RUN)/terraform/%/providers.json ## List the resources in the given Terraform workspace
	@

# =============================================================================
# TF INFO
# =============================================================================

tf-info: tf-schema@$(TERRAFORM_WORKSPACE) ## Lists the resources in the default Terraform workspace
	@

tf-info@%: tf-workspace@% ## List the resources in the given Terraform workspace
	@$(call tf_run,$*,-v)

# =============================================================================
# SHELL
# =============================================================================

tf-shell: tf-shell@$(TERRAFORM_WORKSPACE) ## Starts a shell in $(TERRAFORM_WORKSPACE)
	@

tf-shell@%: tf-workspace@% ## Starts a shell in the given terraform workspace.
	@
	$(call sh_aws_login,$(AWS_ROLE),$(AWS_ACCOUNT))
	function tf {
		$(call tf_cli,$*,"$$@")
	}
	alias terraform=tf
	export tf
	export SHELL_PROMPT_NAME="Terraform Shell Workpace=$* [aws:$$AWS_ROLE@$$AWS_ACCOUNT $(call fmt_aws_account,$(lastword $(subst -,$(SPACE),$*)))]"
	echo "$(RESET)"
	$(call shell_env,env -C "$(PATH_RUN)/terraform/$*" SDK_PATH="$(abspath $(SDK_PATH))" EXTRA_PATH="$(abspath bin):$(abspath src/sh)" TERRAFORM_WORKSPACE="$*" AWS_ACCESS_KEY_ID="$$AWS_ACCESS_KEY_ID" AWS_SECRET_ACCESS_KEY="$$AWS_SECRET_ACCESS_KEY" AWS_SESSION_TOKEN="$$AWS_SESSION_TOKEN" AWS_ENDPOINT_URL="$(TF_AWS_PROVIDER_URL)" PATH="$(abspath $(PATH_RUN)/bin):$(PATH)")

# ------------------------------------------------------------------------------
#
# SUPPORTING RULES
#
# ------------------------------------------------------------------------------

# --
# Creates the backend configuration
$(PATH_RUN)/terraform/%/backend.hcl: $(call use_vars,AWS_REGION TERRAFORM_S3_BUCKET_NAME TERRAFORM_DYNAMODB_NAME TF_AWS_PROVIDER_URL)
	@mkdir -p "$(dir $@)"
	cat > "$@" <<EOL
	# Terraform configuration for workspace $*
	# NOTE: This is automatically generated, do not edit!
	bucket         = "$(TERRAFORM_S3_BUCKET_NAME)"
	key            = "state/$*/terraform.tfstate"
	region         = "$(AWS_REGION)"
	dynamodb_table = "$(TERRAFORM_DYNAMODB_NAME)"
	encrypt        = true
	$(if $(strip $(TF_AWS_PROVIDER_URL)),endpoint = "$(TF_AWS_PROVIDER_URL)")
	$(if $(strip $(TF_AWS_PROVIDER_URL)),dynamodb_endpoint = "$(TF_AWS_PROVIDER_URL)")
	$(if $(strip $(TF_AWS_PROVIDER_URL)),force_path_style = true)
	$(if $(strip $(TF_AWS_PROVIDER_URL)),skip_credentials_validation = true)
	$(if $(strip $(TF_AWS_PROVIDER_URL)),skip_metadata_api_check = true)
	$(if $(strip $(TF_AWS_PROVIDER_URL)),skip_region_validation = true)
	# EOF
	EOL

$(PATH_RUN)/terraform/%/providers.json: tf-workspace@%
	@
	echo "$(call fmt_message,[TFM] Dumping Terraform providers schema: $@)"
	if ! $(call tf_cli,$*,providers schema -json) > "$@"; then
		unlink "$@"
		exit 1
	else
		echo "$(call fmt_message,[TFM] - Schema available at: $@)"
	fi

$(PATH_RUN)/terraform/%/workspace-init.task: $(PATH_RUN)/terraform/%/backend.hcl $(call use_tool,terraform)
	@$(call sh_aws_login,$(AWS_ROLE),$(AWS_ACCOUNT))
	echo "$(call fmt_message,[TFM] Initializing Terraform backend for workspace: $* with config $<)"
	echo "$(call fmt_message,[TFM] - Using configuration: $<)"
	echo "$(call fmt_message,[TFM] - Logging output to: $@)"
	mkdir -p "$(dir $@)"
	date >> "$@"
	env -C "$(dir $@)" $(TF_CLI) init -backend-config="$(abspath $<)" -reconfigure 2>&1 | tee "$@"
	env -C "$(dir $@)" $(TF_CLI) workspace new "$*" 2>&1 | tee "$@"
	touch "$@"

# Copies the terraform sources into the workspace, updating them as necessary.
$(PATH_RUN)/terraform/%/workspace-files.task: $(BUILD_TF) $(call use_vars,TERRAFORM_WORKSPACE)
	@mkdir -p "$(dir $@)"
	date > "$@"
	for F in $(patsubst $(PATH_BUILD)/tf/%,%,$(filter $(PATH_BUILD)/tf/%,$(BUILD_TF))); do
		TARGET="$(dir $@)$$F"
		PARENT="$$(dirname "$$TARGET")"
		mkdir -p "$$PARENT"
		SOURCE="$(PATH_BUILD)/tf/$$F"
		if [ ! -e "$$TARGET" ] || ! cmp --silent -- "$$SOURCE" "$$TARGET" ; then
			cp -aL "$$SOURCE"  "$$TARGET"
			echo "LN '$$SOURCE'  '$$TARGET'" >> "$@"
			echo "$(call fmt_message,[TFM] Copying Terraform source: $(call fmt_path,$$TARGET))"
		fi
	done
	touch "$@"

$(PATH_RUN)/terraform/%/terraform.tfvars: src/tmpl/terraform.tfvars
	@mkdir -p "$(dir $@)"
	if [ -e "$@" ]; then
		chmod +w "$@"
		unlink "$@"
	fi
	cp -aL "$<" "$@"
	echo "$(call fmt_message,[TFM] Copying Terraform variables: $(call fmt_path,$<))"

$(PATH_RUN)/terraform/%/outputs.json: $(PATH_RUN)/terraform/%/updated.log
	@mkdir -p "$(dir $@)"
	$(call tf_run,$*,output -json $(TF_FLAGS), > "$@")

$(PATH_RUN)/terraform/%/outputs.sh: $(PATH_RUN)/terraform/%/updated.log
	@mkdir -p "$(dir $@)"
	$(call tf_run,$*,output $(TF_FLAGS), > "$@")

$(PATH_RUN)/terraform/%/updated.log:
	@mkdir -p "$(dir $@)"
	$(call tf_tag)

$(PATH_BUILD)/tf/%: src/tf/%
	@mkdir -p "$(dir $@)"
	ln -sfr "$<" "$@"

# EOF
