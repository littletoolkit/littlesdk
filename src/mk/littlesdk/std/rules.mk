USE_CLI_CHECK+=|| which $1 2> /dev/null

.PHONY: default
default: $(DEFAULT_RULE)
	@

.PHONY: lint
lint: check ## Alias to `check`
	@

.PHONY: check
check: $(PREP_ALL) $(CHECK_ALL) ## Runs all the checks
	@$(call rule_post_cmd)

.PHONY: fmt
fmt: fix ## Alias to `fix`
	@

.PHONY: fix
fix: $(FIX_ALL) ## Runs all the fixes
	@$(call rule_post_cmd)

.PHONY: build
build: $(PREP_ALL) $(BUILD_ALL) ## Builds all outputs in BUILD_ALL
	@$(call rule_post_cmd)

.PHONY: run
run: $(PREP_ALL) $(RUN_ALL) ## Runs the project
	@$(call rule_post_cmd)

.PHONY: test
test: $(TEST_ALL) ## Builds all tests
	@$(call rule_post_cmd)

.PHONY: dist
dist: $(DIST_ALL)
	@$(call rule_post_cmd)

dist/$(PROJECT)-$(REVISION).tar.xz: dist
	@$(call rule_pre_cmd)
	# Find the most recent mtime
	latest_mtime=$$(find $(PATH_DIST) -type f -exec stat -c '%Y' {} \; | sort -n | tail -1)
	if [ -z "$$latest_mtime" ]; then
		echo "$(call fmt_error,No files found in $(PATH_DIST))"
		exit 1
	fi
	# Set all files to readonly and same timestamp
	find $(PATH_DIST) -type f -exec chmod 444 {} \;
	find $(PATH_DIST) -type f -exec touch --date=@$$latest_mtime {} \;
	find $(PATH_DIST) -type d -exec chmod 555 {} \;
	# Create tarball with max compression, stripping dist/package
	tar cJf $@ -C $(PATH_DIST) .
	@$(call rule_post_cmd,$@)

.PHONY: dist-package
dist-package: dist/$(PROJECT)-$(REVISION).tar.xz

.PHONY: dist-info
dist-info: ## Shows distribution files with sizes and total
	@$(call rule_pre_cmd)
	total_size=0
	file_count=0
	missing_count=0
	echo ""
	echo "$(BOLD)Distribution files$(RESET) (DIST_ALL):"
	echo ""
	for file in $(DIST_ALL); do
		if [ -f "$$file" ]; then
			size=$$(stat -c%s "$$file")
			total_size=$$((total_size + size))
			file_count=$$((file_count + 1))
			if [ $$size -ge 1048576 ]; then
				human_size=$$(printf "%.1fM" $$(echo "scale=1; $$size / 1048576" | bc))
			elif [ $$size -ge 1024 ]; then
				human_size=$$(printf "%.1fK" $$(echo "scale=1; $$size / 1024" | bc))
			else
				human_size="$${size}B"
			fi
			printf "  %8s  %s\n" "$$human_size" "$$file"
		else
			missing_count=$$((missing_count + 1))
			printf "  %8s  %s\n" "$(DIM)missing$(RESET)" "$$file"
		fi
	done
	echo ""
	if [ $$total_size -ge 1048576 ]; then
		human_total=$$(printf "%.2fM" $$(echo "scale=2; $$total_size / 1048576" | bc))
	elif [ $$total_size -ge 1024 ]; then
		human_total=$$(printf "%.2fK" $$(echo "scale=2; $$total_size / 1024" | bc))
	else
		human_total="$${total_size}B"
	fi
	echo "$(BOLD)Total$(RESET): $$file_count files, $$human_total ($$total_size bytes)"
	if [ $$missing_count -gt 0 ]; then
		echo "$(call fmt_tip,$$missing_count files missing. Run $(BOLD)make dist$(RESET) to create them)"
	fi

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
	@env -i TERM=$(TERM) "PATH=$(ENV_PATH)" "PYTHONPATH=$(ENV_PYTHONPATH)" bash --noprofile --rcfile "$(SDK_PATH)/src/sh/std.prompt.sh"

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
# Ensures thath teh given CLI tool is installed
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
