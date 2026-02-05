# -----------------------------------------------------------------------------
#
# STANDARD LIBRARY RULES
#
# -----------------------------------------------------------------------------

# Standard build rules and targets for LittleSDK projects.
# These provide the core build lifecycle: prep, build, check, test, dist, clean.

# --
# ## CLI Check Integration

USE_CLI_CHECK+=|| which $1 2> /dev/null ## Extend CLI check command

# -----------------------------------------------------------------------------
#
# DEFAULT RULE
#
# -----------------------------------------------------------------------------

.PHONY: default
default: $(DEFAULT_RULE) ## Default target (runs DEFAULT_RULE)
	@

# -----------------------------------------------------------------------------
#
# PREPARATION
#
# -----------------------------------------------------------------------------

.PHONY: prep
prep: $(PREP_ALL) ## Prepares dependencies and environment
	@

# -----------------------------------------------------------------------------
#
# CHECK AND FIX
#
# -----------------------------------------------------------------------------

# --
# ## Code Quality

.PHONY: lint
lint: check ## Alias for check
	@

.PHONY: check
check: $(PREP_ALL) $(CHECK_ALL) ## Runs all checks (linting, audits, formatting)
	@$(call rule_post_cmd)

.PHONY: fmt
fmt: fix ## Alias for fix
	@

.PHONY: fix
fix: $(PREP_ALL) $(FIX_ALL) ## Runs all fixes (auto-fix formatting issues)
	@$(call rule_post_cmd)

# -----------------------------------------------------------------------------
#
# BUILD
#
# -----------------------------------------------------------------------------

.PHONY: build
build: $(PREP_ALL) $(BUILD_ALL) ## Builds all outputs defined in BUILD_ALL
	@$(call rule_post_cmd)

# -----------------------------------------------------------------------------
#
# RUN
#
# -----------------------------------------------------------------------------

.PHONY: run
run: $(PREP_ALL) $(RUN_ALL) ## Runs the project
	@$(call rule_post_cmd)

# -----------------------------------------------------------------------------
#
# TEST
#
# -----------------------------------------------------------------------------

.PHONY: test
test: $(PREP_ALL) $(TEST_ALL) ## Runs all tests
	@$(call rule_pre_cmd)
	failed_tests=0
	for test in $(TESTS_SH); do
		echo "$(call fmt_action,[TEST] Running $$test)"
		if ! bash "$$test"; then
			echo "$(call fmt_error,[TEST] FAILED: $$test)"
			failed_tests=$$((failed_tests + 1))
		fi
	done
	if [ $$failed_tests -gt 0 ]; then
		echo "$(call fmt_error,[TEST] $$failed_tests test(s) failed)"
		exit 1
	fi
	@echo "$(call fmt_result,[TEST] All tests passed)"
	@$(call rule_post_cmd)

# -----------------------------------------------------------------------------
#
# DISTRIBUTION
#
# -----------------------------------------------------------------------------

# --
# ## Distribution Targets

.PHONY: dist
dist: $(PREP_ALL) $(DIST_ALL) ## Creates distribution packages
	@$(call rule_post_cmd)

# --
# Function: create_compressed_archive
# Creates a compressed archive with consistent permissions and timestamps.
# - ARCHIVE: Target archive file path
# - FORMAT: Compression format (gz, bz2, xz)
# - FLAG: Tar compression flag (z, j, J)
# - LEVEL: Compression level (1-9)
# Returns: Shell commands to create archive

define create_compressed_archive
	@$(call rule_pre_cmd)
	# Find the most recent mtime
	latest_mtime=$$(find $(PATH_DIST) -type f -exec stat -c '%Y' {} \; | sort -n | tail -1)
	if [ -z "$$latest_mtime" ]; then
		echo "$(call fmt_error,[STD] No files found in $(PATH_DIST))"
		exit 1
	fi
	# Create temporary directory with desired permissions for archiving
	temp_dist="$$(mktemp -d)"
	cp -rp $(PATH_DIST)/* "$$temp_dist"/
	find "$$temp_dist" -type f -executable -exec chmod 555 {} \;
	find "$$temp_dist" -type f ! -executable -exec chmod 444 {} \;
	find "$$temp_dist" -type d -exec chmod 555 {} \;
	# Create tarball with specified compression
	if ! $(CMD) tar c$3f $1 --mtime="@$$latest_mtime" -C "$$temp_dist" .; then
		rm -f $1
		chmod -R u+w "$$temp_dist"
		rm -rf "$$temp_dist"
		echo "$(call fmt_error,[STD] Failed to create tarball)"
		exit 1
	fi
	# Restore write permissions for cleanup and remove temporary directory
	chmod -R u+w "$$temp_dist"
	rm -rf "$$temp_dist"
	@$(call rule_post_cmd,$1)
endef

# Ensure distribution directory exists
$(PATH_DIST):
	@mkdir -p $@

# Archive targets
dist/$(PROJECT)-$(REVISION).tar.gz: $(DIST_ALL) $(MAKEFILE_LIST) | $(PATH_DIST)
	$(call create_compressed_archive,$@,gz,z,$(COMPRESS_GZ_LEVEL))

dist/$(PROJECT)-$(REVISION).tar.bz2: $(DIST_ALL) $(MAKEFILE_LIST) | $(PATH_DIST)
	$(call create_compressed_archive,$@,bz2,j,$(COMPRESS_BZ2_LEVEL))

dist/$(PROJECT)-$(REVISION).tar.xz: $(DIST_ALL) $(MAKEFILE_LIST) | $(PATH_DIST)
	$(call create_compressed_archive,$@,xz,J,$(COMPRESS_XZ_LEVEL))

.PHONY: dist-package
dist-package: $(DIST_PACKAGES) ## Creates all distribution packages

.PHONY: dist-package-gz dist-package-bz2 dist-package-xz
dist-package-gz: dist/$(PROJECT)-$(REVISION).tar.gz ## Creates gzip-compressed distribution
dist-package-bz2: dist/$(PROJECT)-$(REVISION).tar.bz2 ## Creates bzip2-compressed distribution
dist-package-xz: dist/$(PROJECT)-$(REVISION).tar.xz ## Creates xz-compressed distribution

.PHONY: dist-info
dist-info: ## Shows distribution files with sizes and totals
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
		echo "$(call fmt_tip,[STD] $$missing_count files missing. Run $(BOLD)make dist$(RESET) to create them)"
	fi

# -----------------------------------------------------------------------------
#
# HELP
#
# -----------------------------------------------------------------------------

.PHONY: help
help: ## Shows this help message
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

.PHONY: help-vars
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

# -----------------------------------------------------------------------------
#
# CLEANUP
#
# -----------------------------------------------------------------------------

.PHONY: clean
clean: ## Removes build, run, and dist directories
	@$(call rule_pre_cmd)
	for dir in build run dist $(CLEAN_ALL); do
		if [ -d "$$dir" ]; then
			count=$$(find $$dir -name '*' | wc -l)
			echo "$(call fmt_action,[STD] Cleaning up directory: $(call fmt_path,$$dir)) [$$count]"
			rm -rf "$$dir"
		elif [ -e "$$dir" ]; then
			echo "$(call fmt_action,[STD] Cleaning up file: $(call fmt_path,$$dir))"
			unlink "$$dir"
		fi
	done

# -----------------------------------------------------------------------------
#
# DEVELOPMENT
#
# -----------------------------------------------------------------------------

# --
# ## Development Helpers

.PHONY: shell
shell: ## Opens a shell with SDK environment configured
	@env -i TERM=$(TERM) "PATH=$(ENV_PATH)" "PYTHONPATH=$(ENV_PYTHONPATH)" bash --noprofile --rcfile "$(SDK_PATH)/src/sh/std.prompt.sh"

.PHONY: live-%
live-%: ## Auto-rebuilds target when source files change
	@$(call rule_pre_cmd)
	echo $(SOURCES_ALL) | xargs -n1 echo | entr -c -r bash -c 'sleep 0.25 && make $* $(MAKEFLAGS)'

.PHONY: print-%
print-%: ## Shows the value of any variable
	@$(info $(BOLD)$*=$(RESET)$(EOL)$(strip $($*))$(EOL)$(BOLD)END$(RESET))

.PHONY: list-%
list-%: ## Shows the value of any variable as a list
	@$(info $(BOLD)$*=$(RESET)$(EOL)$(foreach V,$(strip $($*)),$V$(EOL))$(EOL)$(BOLD)END$(RESET))

.PHONY: def-%
def-%: ## Shows the definition of any variable or function
	@$(info $(BOLD)$*=$(RESET)$(EOL)$(value $*)$(EOL)$(BOLD)END$(RESET))

# -----------------------------------------------------------------------------
#
# CLI TOOLS
#
# -----------------------------------------------------------------------------

# --
# ## CLI Tool Verification

# Ensures the given CLI tool is installed and creates a marker file
$(PATH_BUILD)/cli-%.task:
	CLI_PATH="$$(test -e "run/bin/$*" && echo "run/bin/$*" $(call USE_CLI_CHECK,$*) || true)"
	if [ -z "$$CLI_PATH" ]; then
		echo "$(call fmt_error,[STD] Could not find CLI tool: $*)"
		test -e "$@" && unlink "$@"
		exit 1
	else
		mkdir -p "$(dir $@)"
		echo "$$CLI_PATH" > "$@"
		touch --date=@0 "$@"
		echo "$(call fmt_result,[STD] OK: $$CLI_PATH)"
	fi

# -----------------------------------------------------------------------------
#
# SDK FILE LINKING
#
# -----------------------------------------------------------------------------

# --
# ## Dotfile Linking

# --
# Function: prep-link
# Creates a rule to link a dotfile or config file.
# - DST: Destination path (in project root)
# - SRC: Source path (in SDK etc/ directory)
# Returns: Makefile rule definition

define prep-link
$(EOL)
$(1): $(2)
	@$$(call rule_pre_cmd)
	if [ -d "$$<" ]; then
		if ! mkdir -p "$$@"; then
			echo "$(call fmt_error,[SDK] This should be a directory $(call fmt_path,$$@): unable to create it)"
			exit 1
		fi
	elif [ -e "$$@" ]; then
		if [ -L "$$@" ]; then
			unlink "$$@"
		else
			echo "$(call fmt_warn,[SDK] Skipping file $(call fmt_path,$$@): already exists and is not a symlink)"
			exit 0
		fi
	else
		mkdir -p "$$(dir $$@)";
		ln -sfr "$$<" "$$@";
	fi
$(EOL)
endef

# Link dotfiles (prefixed with _ in SDK become . in project)
$(eval $(call prep-link,.%,$(SDK_PATH)/etc/_%))
$(eval $(call prep-link,%,$(SDK_PATH)/etc/%))
$(eval $(foreach F,$(strip $(PREP_SDK)),$(call prep-link,$F,$(SDK_PATH)/etc/$(patsubst .%,_%,$F))))

# EOF
