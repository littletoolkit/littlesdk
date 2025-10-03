USE_CLI_CHECK+=|| which $1 2> /dev/null

.PHONY: default
default: $(DEFAULT_RULE)
	@

.PHONY: build
build: $(BUILD_ALL) ## Builds all outputs in BUILD_ALL
	@$(call rule_post_cmd)

.PHONY: dist
dist: $(DIST_ALL)
	@$(call rule_post_cmd)

.PHONY: help
help: ## This command
	@$(call rule_pre_cmd)
	cat << EOF
	…
	📖 $(BOLD)LittleSDK$(RESET) phases:
	$(call fmt_rule,prep)     ― Installs dependencies & prepares environment
	$(call fmt_rule,build)    ― Builds all the assets required to run and distribute
	$(call fmt_rule,run)      ― Runs the project and its dependencies
	$(call fmt_rule,dist)     ― Creates distributions of the project
	$(call fmt_rule,deploy)   ― Deploys the project on an infrastructure
	$(call fmt_rule,release)  ― Finalise a deployment so that it is in production
	―
	$(call fmt_rule,check)    ― Lints, audits and formats the code
	$(call fmt_rule,test)     ― Runs tests
	EOF
	dev_rules=()
	main_rules=()
	for SRC in $(filter %/rules.mk,$(MODULES_SOURCES)); do
		while read -r line; do
			rule=$${line%%:*}
			origin=$$(dirname $$SRC)
			case "$$rule" in
				*/*)
					dev_rules+=("$(call fmt_rule,$$rule,🗅) ―$${line##*##} $(DIM)[$$origin]$(RESET)") # NOHELP
					;;
				*)
					main_rules+=("$(call fmt_rule,$$rule) ―$${line##*##} $(DIM)[$$origin]$(RESET)") # NOHELP
					;;
			esac
		done < <(grep '##' $(MODULES_PATH)/$$SRC | grep -v NOHELP) # NOHELP
	done
	if [ ! $${#main_rules[@]} -eq 0 ]; then
		echo ""
		echo "Available $(BOLD)rules$(RESET):"
		printf '%s\n' "$${main_rules[@]}" | sort
	fi
	if [ ! $${#dev_rules[@]} -eq 0 ]; then
		echo
		echo "Available $(BOLD)development rules$(RESET):"
		printf '%s\n' "$${dev_rules[@]}" | sort
	fi

help-vars: ## Shows available configuration variables
	@
	vars=()
	for SRC in $(filter %/config.mk,$(MODULES_SOURCES)); do
		while read -r line; do
			varname=$${line%%=*}
			vars+=("$(BOLD)$${varname//[:?]/} $(DIM)[$$(dirname $$SRC)]$(RESET)") # NOHELP
		done < <(grep '=' $(MODULES_PATH)/$$SRC | grep -v NOHELP | grep -v '#')
	done
	printf '%s\n' "$${vars[@]}" | sort
	echo "$(call fmt_tip,Run the following to see the value of the variable: $(BOLD)make print-VARNAME$(DIM))"

.PHONY: clean
clean: ## Cleans the project, removing build and run files
	@$(call rule_pre_cmd)
	for dir in build run dist $(CLEAN_ALL); do
		if [ -d "$$dir" ]; then
			count=$$(find $$dir -name '*' | wc -l)
			echo "$(call fmt_action,Cleaning up directory: $(call fmt_path,$$dir)) [$$count]"
			rm -rf "$$dir"
		elif [ -e "$$dir" ]; then
			echo "$(call fmt_action,Cleaning up file: $(call fmt_path,$$dir))"
			unlink "$$dir"
		fi
	done


.PHONY: shell
shell: ## Opens a shell setup with the environment
	@env -i TERM=$(TERM) "PATH=$(ENV_PATH)" "PYTHONPATH=$(ENV_PYTHONPATH)" bash --noprofile --rcfile "$(LB_PATH)/src/sh/std.prompt.sh"

.PHONY: live-%
live-%:
	@$(call rule_pre_cmd)
	echo $(SOURCES_ALL) | xargs -n1 echo | entr -c -r bash -c 'sleep 0.25 && make $* $(MAKEFLAGS)'

.PHONY: print-%
print-%:
	@$(info $(BOLD)$*=$(RESET)$(EOL)$(strip $($*))$(EOL)$(BOLD)END$(RESET))

.PHONY: def-%
def-%:
	@$(info $(BOLD)$*=$(RESET)$(EOL)$(value $*)$(EOL)$(BOLD)END$(RESET))

# --
# Ensures thath teh given CLI tool is instatlled
$(PATH_BUILD)/cli-%.task:
	CLI_PATH="$$(test -e "run/bin/$*" && echo "run/bin/$*" $(call USE_CLI_CHECK,$*) || true)"
	if [ -z "$$CLI_PATH" ]; then
		echo "$(call fmt_error,Could not find CLI tool: $*)"
		test -e "$@" && unlink "$@"
		exit 1
	else
		mkdir -p "$(dir $@)"
		echo "$$CLI_PATH" > "$@"
		touch --date=@0 "$@"
		echo "$(call fmt_result,OK: $$CLI_PATH)"
	fi
# EOX
