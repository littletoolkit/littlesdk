help: ## This command
	@$(call rule-pre-cmd)
	cat << EOF
	…
	📖 $(BOLD)LittleDevKit$(RESET) phases:
	$(call fmt-rule,prep)     ― Installs dependencies & prepares environment
	$(call fmt-rule,build)    ― Builds all the assets required to run and distribute
	$(call fmt-rule,run)      ― Runs the project and its dependencies
	$(call fmt-rule,dist)     ― Creates distributions of the project
	$(call fmt-rule,deploy)   ― Deploys the project on an infrastructure
	$(call fmt-rule,release)  ― Finalise a deployment so that it is in production
	―
	$(call fmt-rule,check)    ― Lints, audits and formats the code
	$(call fmt-rule,test)     ― Runs tests
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
					dev_rules+=("$$origin $(call fmt-rule,$$rule,🗅) ―$${line##*##}") # NOHELP
					dev_rules+=("EOL")
					;;
				*)
					echo "$$origin $(call fmt-rule,$$rule) ―$${line##*##}" # NOHELP
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
	echo "$(call fmt-tip,Run the following to see the value of the variable: $(BOLD)make print-VARNAME$(DIM))"

clean: ## Cleans the project, removing build and run files
	@$(call rule-pre-cmd)
	for dir in build run dist; do
		if [ -e "$$dir" ]; then
			count=$$(find $$dir -name '*' | wc -l)
			echo "$(call fmt-action,Cleaning up directory: $(call fmt-path,$$dir)) [$$count]"
			rm -rf "$$dir"
		fi
	done

shell: ## Opens a shell setup with the environment
	@env -i TERM=$(TERM) PATH=$(realpath bin):$(DEPS_PATH):$(BASE_PATH) PYTHONPATH=$(realpath src/py):$(DEPS_PYTHONPATH):$(BASE_PYTHONPATH) bash --noprofile --rcfile "$(KIT_PATH)/src/sh/std.prompt.sh"

print-%:
	@$(info $(BOLD)$*=$(RESET)$(EOL)$(strip $($*))$(EOL)$(BOLD)END$(RESET))

def-%:
	@$(info $(BOLD)$*=$(RESET)$(EOL)$(value $*)$(EOL)$(BOLD)END$(RESET))

# EOF
