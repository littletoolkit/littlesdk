.PHONY: default
default: $(DEFAULT_RULE)
	@

.PHONY: help
help: ## This command
	@$(call rule_pre_cmd)
	cat << EOF
	…
	📖 $(BOLD)LittleDevKit$(RESET) phases:
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
	echo ""
	echo "Available $(BOLD)rules$(RESET):"
	dev_rules=()
	for SRC in $(filter %/rules.mk,std/rules.mk $(KIT_MODULES_SOURCES)); do
		while read -r line; do
			rule=$${line%%:*}
			origin=`printf "%-11.11s" $$(dirname $$SRC)`
			case "$$rule" in
				*/*)
					dev_rules+=("$$origin $(call fmt_rule,$$rule,🗅) ―$${line##*##}") # NOHELP
					dev_rules+=("EOL")
					;;
				*)
					echo "$$origin $(call fmt_rule,$$rule) ―$${line##*##}" # NOHELP
					;;
			esac
		done < <(grep '##' $(KIT_MODULES_PATH)/$$SRC | grep -v NOHELP) # NOHELP
	done
	if [ ! $${#dev_rules[@]} -eq 0 ]; then
		echo
		echo "Available $(BOLD)development rules$(RESET):"
		for word in "$${dev_rules[@]}"; do
			case "$$word" in
				EOL) echo ;;
				*) echo -n "$$word " ;;
			esac
		 done
	 fi

help-vars: ## Shows available configuration variables
	@
	for SRC in $(filter %/config.mk,$(KIT_MODULES_SOURCES)); do
		while read -r line; do
			varname=$${line%%=*}
			echo "[$$(dirname $$SRC)]$(BOLD)" $${varname//[:?]/}"$(RESET)" # NOHELP
		done < <(grep '=' $(KIT_MODULES_PATH)/$$SRC | grep -v NOHELP)
	done
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

.PHONY: build
build: $(BUILD_ALL) ## Builds all outputs in BUILD_ALL
	@

.PHONY: shell
shell: ## Opens a shell setup with the environment
	@env -i TERM=$(TERM) "PATH=$(ENV_PATH)" "PYTHONPATH=$(ENV_PYTHONPATH)" bash --noprofile --rcfile "$(KIT_PATH)/src/sh/std.prompt.sh"

live-%:
	@$(call rule_pre_cmd)
	echo $(SOURCES_ALL) | xargs -n1 echo | entr -c -r bash -c 'sleep 0.25 && make $* $(MAKEFLAGS)'

print-%:
	@$(info $(BOLD)$*=$(RESET)$(EOL)$(strip $($*))$(EOL)$(BOLD)END$(RESET))

def-%:
	@$(info $(BOLD)$*=$(RESET)$(EOL)$(value $*)$(EOL)$(BOLD)END$(RESET))

# EOF
