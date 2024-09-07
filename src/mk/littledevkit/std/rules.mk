help: ## This command
	@cat << EOF
	🧰 $(BOLD)LittleDevKit$(RESET) phases:
	▸ $(BOLD)prep$(RESET)     ― Installs dependencies & prepares environment
	▸ $(BOLD)build$(RESET)    ― Builds all the assets required to run and distribute
	▸ $(BOLD)run$(RESET)      ― Runs the project and its dependencies
	▸ $(BOLD)dist$(RESET)     ― Creates distributions of the project
	▸ $(BOLD)deploy$(RESET)   ― Deploys the project on an infrastructure
	▸ $(BOLD)release$(RESET)  ― Finalise a deployment so that it is in production
	―
	▸ $(BOLD)check$(RESET)    ― Lints, audits and formats the code
	▸ $(BOLD)test$(RESET)     ― Runs tests
	EOF
	echo ""
	echo "Available $(BOLD)rules$(RESET):"
	dev_rules=()
	for SRC in $(filter %/rules.mk,std/rules.mk $(KIT_MODULES_SOURCES)); do
		while read -r line; do
			rule=$${line%%:*}
			fmt_line="▸ $$(dirname $$SRC)"$$'\t'"$(BOLD)$$rule$(RESET) → $${line##*##}" # NOHELP
			case "$$rule" in
				*/*)
					dev_rules+=("$$fmt_line")
					dev_rules+=("EOL")
					;;
				*)
					echo "$$fmt_line"
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

# EOF
