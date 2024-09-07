help: ## This command
	@for SRC in $(filter %/rules.mk,std/rules.mk $(KIT_MODULES_SOURCES)); do
		while read -r line; do
			echo [$$(dirname $$SRC)] $(BOLD)$${line%%:*}$(RESET) → $${line##*##} # NOHELP
		done < <(grep '##' $(KIT_MODULES_PATH)/$$SRC | grep -v NOHELP) # NOHELP
	done

help-vars: ## Shows available configuration variables
	@for SRC in $(filter %/config.mk,$(KIT_MODULES_SOURCES)); do
		while read -r line; do
			RULE=$${line%%=*}
			echo "[$$(dirname $$SRC)] $(BOLD)" $${RULE//[:?]/}"$(RESET)" → $${line##*##} # NOHELP
		done < <(grep '=' $(KIT_MODULES_PATH)/$$SRC | grep -v NOHELP)
	done

# EOF
