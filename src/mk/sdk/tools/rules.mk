# Macro: tool_package_find
# A shell script that looks in the tools whitelist for a matching package with
# the given name for the given distribution.
define sh_tool_package_find
WHITELIST_PATH="$(realpath $(TOOLS_WHITELIST))"
if ! [ -e "$$WHITELIST_PATH" ]; then
	echo "$(call fmt_error,[TLS] Package whitelist is missing: '$$WHITELIST_PATH')"
	exit 1
fi
PACKAGE_NAME=""
PACKAGE_SPEC=""
PACKAGE_VERSION=""
PACKAGE_ALIAS=""
TARGET_TOOL="$1"
TARGET_PKG_MGR="$2"
while IFS= read -r LINE || [ -n "$$LINE" ]; do
	TOOL_NAME="$${LINE%%=*}"
	if [ "$$TOOL_NAME" == "$$TARGET_TOOL" ]; then
		echo "$(call fmt_message,[TLS] Tool '$$TARGET_TOOL' found in whitelist: $$LINE)"
		SPECS="$${LINE##*=}"
		SPECS_SPLIT="$$(echo "$$SPECS" | tr ',' ' ')"
		for SPEC in $$SPECS_SPLIT; do
			SPEC_CLEANED="$$(echo "$$SPEC" | tr ':' ' ')"
			set -- $$SPEC_CLEANED
			FIELD_0="$$1"
			FIELD_1="$$2"
			FIELD_2="$$3"
			if [ "$$FIELD_0" == "$$TARGET_PKG_MGR" ]; then
				PACKAGE_SPEC="$$LINE"
				PACKAGE_NAME="$$FIELD_1"
				PACKAGE_ALIAS="$$FIELD_2"
				break
			fi
		done
		break
	fi
done < "$$WHITELIST_PATH"
if [ -z "$$PACKAGE_SPEC" ]; then
	echo "$(call fmt_error,[TLS] No package '$$TARGET_TOOL' for '$$TARGET_PKG_MGR' in: $$WHITELIST_PATH)"
	exit 1
else
	echo "$(call fmt_message,[TLS] Found tool '$$TARGET_TOOL' for '$$TARGET_PKG_MGR': name='$$PACKAGE_NAME' version='$$PACKAGE_VERSION' alias='$$PACKAGE_ALIAS')"

fi
endef

define sh_tool_install_alias
	if [ -n "$$PACKAGE_ALIAS" ]; then
		if TOOL_PATH="$$(which "$$PACKAGE_ALIAS")"; then
			mkdir -p "$(PATH_RUN)/bin"
			echo "$(call fmt_message,[TLS] Creating alias for '$$PACKAGE_ALIAS' for $*: $(call fmt_path,$(PATH)/bin/$*))"
			ln -sf "$$TOOL_PATH" "$(PATH_RUN)/bin/$*";
		else
			echo "$(call fmt_message,[TLS] Could not find package alias '$$PACKAGE_ALIAS' for $*)"
			exit 1
		fi
	fi
endef


# -----------------------------------------------------------------------------
# VENDORED TOOLS
# -----------------------------------------------------------------------------

# A macro that install litlesecrets and multiplex locally
$(foreach T,littlesecrets multiplex git-deps,$(PATH_RUN_TASK)/tool-$T.task): $(PATH_RUN_TASK)/tool-%.task: $(PATH_RUN)/bin/%
	@
	mkdir -p "$(dir $@)"
	echo "$(realpath $<)" > "$@"

# Tool: littlesecrets
# Secrets manager
$(PATH_RUN)/bin/littlesecrets: $(call use_vars,TOOL_LITTLESECRETS_COMMIT)
	@$(call shell_download,$(call tool_github_file,littletoolkit/littlesecrets,src/sh/littlesecrets.sh,$(TOOL_LITTLESECRETS_COMMIT)))
	chmod +x "$@"
	echo "$(call fmt_result,[TLS] Tool installed: $(call fmt_output,$@))"


# Tool: multiplex
# Commmand-line multiplexer
$(PATH_RUN)/bin/multiplex: $(call use_vars,TOOL_MULTIPLEX_COMMIT)
	@$(call shell_download,$(call tool_github_file,sebastien/multiplex,src/py/multiplex.py,$(TOOL_MULTIPLEX_COMMIT)))
	chmod +x "$@"
	echo "$(call fmt_result,[TLS] Tool installed: $(call fmt_output,$@))"

# Tool: git-deps
# Dependency management for git
$(PATH_RUN)/bin/git-deps: $(call use_vars,TOOL_GITDEPS_COMMIT)
	@$(call shell_download,$(call tool_github_file,sebastien/git-deps,src/sh/git-deps.sh,$(TOOL_GITDEPS_COMMIT)))
	chmod +x "$@"
	echo "$(call fmt_result,[TLS] Tool installed: $(call fmt_output,$@))"

# -----------------------------------------------------------------------------
# PACKAGES
# -----------------------------------------------------------------------------

$(eval $(foreach T,$(TOOLS_SYSTEM_AVAILABLE),$(EOL)$(PATH_RUN_TASK)/tool-$T.task: $(PATH_RUN)/bin/$T$(EOL)	@mkdir -p $(PATH_RUN)/task;touch "$$@"$(EOL)))

$(foreach T,$(TOOLS_SYSTEM_AVAILABLE),$(PATH_RUN)/bin/$T) : $(PATH_RUN)/bin/%: $(PATH_RUN_TASK)/install-package-%.task
	@echo "$(call fmt_message,[TLS] Linking tool: '$*' installed from $^)"
	TOOL_PATH="$$(env PATH="$(realpath $(PATH_RUN)/bin):$$PATH" which $* 2> /dev/null ; true)"
	if [ -z "$$TOOL_PATH" ]; then
		echo "$(call fmt_error,[TLS] Could not find tool: '$*' installed from $^)"
		echo "$(call fmt_tip,[TLS] Run 'rm $^' and try again)"
		exit 1
	else
		TOOL_PATH=$$(realpath "$$TOOL_PATH")
		if [ ! -e "$@" ]; then
			ln -sf "$$TOOL_PATH" "$@"
			echo "$(call fmt_result,[TLS] Tool installed: $(call fmt_output,$*))"
		else
			echo "$(call fmt_result,[TLS] Tool already installed: $(call fmt_output,$*))"
		fi
	fi


tool-install-%: $(PATH_RUN_TASK)/install-%.task ## Installs the package from TOOLS_WHITELIST
	@

# Generic package installation that delegates to the appropriate package manager
$(PATH_RUN_TASK)/install-package-%.task: $(PATH_RUN_TASK)/install-$(SYSTEM_PACKAGE_MANAGER)-%.task ## Installs a package using the detected package manager
	@mkdir -p "$(dir $@)"
	if [ "$(SYSTEM_PACKAGE_MANAGER)" = "unknown" ]; then
		echo "$(call fmt_error,[TLS] Unsupported package manager: $(SYSTEM_PACKAGE_MANAGER))"
		exit 1
	fi
	echo "# LINK:$<" > "$@"

tool-install-rpm-%: $(PATH_RUN_TASK)/install-rpm-%.task ## Installs the RPM package from TOOLS_WHITELIST
	@

# RPM-based package installation (RHEL, CentOS, Fedora)
$(PATH_RUN_TASK)/install-rpm-%.task: ## Installs an RPM package
	@mkdir -p "$(dir $@)"
	$(call sh_tool_package_find,$*,rpm)
	if [ -z "$$PACKAGE_VERSION" ]; then
		echo "$(call fmt_message,[TLS] Installing RPM package: $$PACKAGE_NAME)"
		if command -v dnf >/dev/null 2>&1; then
			sudo dnf install -y "$$PACKAGE_NAME"
		elif command -v yum >/dev/null 2>&1; then
			sudo yum install -y "$$PACKAGE_NAME"
		else
			echo "$(call fmt_error,[TLS] No RPM package manager found (dnf/yum))"
			exit 1
		fi
	else
		echo "$(call fmt_message,[TLS] Installing RPM package: $$PACKAGE_NAME version $$PACKAGE_VERSION)"
		if command -v dnf >/dev/null 2>&1; then
			sudo dnf install -y "$${PACKAGE_NAME}-$${PACKAGE_VERSION}"
		elif command -v yum >/dev/null 2>&1; then
			sudo yum install -y "$${PACKAGE_NAME}-$${PACKAGE_VERSION}"
		else
			echo "$(call fmt_error,[TLS] No RPM package manager found (dnf/yum))"
			exit 1
		fi
	fi
	$(call sh_tool_install_alias)
	touch "$@"

tool-install-deb-%: $(PATH_RUN_TASK)/install-deb-%.task ## Installs the DEB package from TOOLS_WHITELIST
	@

# DEB-based package installation (Debian, Ubuntu)
$(PATH_RUN_TASK)/install-deb-%.task: ## Installs a DEB package
	@mkdir -p "$(dir $@)"
	$(call sh_tool_package_find,$*,deb)
	if [ -z "$$PACKAGE_VERSION" ; then
		echo "$(call fmt_message,[TLS] Installing DEB package: $$PACKAGE_NAME)"
		sudo apt-get update && sudo apt-get install -y "$$PACKAGE_NAME"
	else
		echo "$(call fmt_message,[TLS] Installing DEB package: $$PACKAGE_NAME version $$PACKAGE_VERSION)"
		sudo apt-get update && sudo apt-get install -y "$${PACKAGE_NAME}=$${PACKAGE_VERSION}"
	fi
	$(call sh_tool_install_alias)
	touch "$@"

tool-install-brew-%: $(PATH_RUN_TASK)/install-brew-%.task
	@

# Homebrew package installation (macOS, Linux)
$(PATH_RUN_TASK)/install-brew-%.task:  ## Installs the DEB package from TOOLS_WHITELIST
	@mkdir -p "$(dir $@)"
	$(call sh_tool_package_find,$*,brew)
	if [ -z "$$PACKAGE_VERSION" ]; then
		echo "$(call fmt_message,[TLS] Installing Homebrew package: $$PACKAGE_NAME)"
		brew install "$$PACKAGE_NAME"
	else
		echo "$(call fmt_message,[TLS] Installing Homebrew package: $$PACKAGE_NAME version $$PACKAGE_VERSION)"
		brew install "$${PACKAGE_NAME}@$${PACKAGE_VERSION}"
	fi
	$(call sh_tool_install_alias)
	touch "$@"

$(PATH_RUN_TASK)/git-deps-checkout.task: $(wildcard .gitdeps .jjdeps) $(PATH_RUN)/bin/git-deps
	@mkdir -p "$(dir $@)"
	$(PATH_RUN)/bin/git-deps checkout
	touch "$@"

# -----------------------------------------------------------------------------
# TASKS
# -----------------------------------------------------------------------------

$(PATH_RUN_TASK)/tool-%.task: ## Ensures the given tool is available
	@if [ -e "$(PATH_RUN)/bin/$*" ] || command -v $* >/dev/null 2>&1; then
		mkdir -p "$(dir $@)"
		touch -t 200001010000 "$@"
		echo "$(call fmt_message,[SDK] Found CLI tool: $(BOLD)$*)"
	elif [ -n "$(wildcard mise.toml)" ]; then
		if ! command -v mise >/dev/null 2>&1; then
			echo "$(call fmt_error,[SDK] Found mise.toml but mise is not installed)"
			echo "$(call fmt_tip,Install mise with: $(call fmt_makecmd,$(PATH_RUN_TASK)/tool-mise.task))"
			exit 1
		fi
		if mise which "$*" >/dev/null 2>&1; then
			mkdir -p "$(dir $@)"
			touch -t 200001010000 "$@"
			echo "$(call fmt_message,[SDK] Found CLI tool via mise.toml: $(BOLD)$*)"
		else
			echo "$(call fmt_error,[SDK] Tool $(BOLD)$* is not configured/installed in mise.toml)"
			echo "$(call fmt_tip,Install configured mise tools with: $(call fmt_makecmd,$(PATH_RUN_TASK)/tool-mise.task))"
			if [ -e "$@" ]; then unlink "$@"; fi
			exit 1
		fi
	else
		echo "$(call fmt_error,[SDK] Could not find CLI tool: $(BOLD)$*)"
		if [ -e "$@" ]; then unlink "$@"; fi
		exit 1
	fi

$(PATH_RUN_TASK)/tool-mise.task: ## Installs mise
	@if [ -z "$$(which mise 2> /dev/null)" ]; then
		if curl https://mise.run | sh; then
			echo "$(call fmt_message,[SDK] Installed mise)"
			mkdir -p "$(dir $@)"
			touch -t 200001010000 "$@"
		fi
	fi
	if [ -z "$$(which mise 2> /dev/null)" ]; then
		$(call shell_fail,Failed to install mise see https://mise.jdx.dev/installing-mise.html)
	fi
	if [ -n "$(wildcard mise.toml)" ]; then
		if ! mise trust --yes 2>/dev/null; then $(call shell_fail,Failed to source mise.toml); fi
		if ! mise install;     then $(call shell_fail,Failed to install mise.toml); fi
	fi
	mkdir -p "$(dir $@)"
	touch -t 200001010000 "$@"

# Task: Verify GNU coreutils are available via mise
$(PATH_RUN_TASK)/check-gnu-tools.task: $(call use_tool,mise)
	@mkdir -p "$(dir $@)"
	if command -v mise >/dev/null 2>&1; then
		if mise x -- env --version 2>/dev/null | head -1 | grep -q 'GNU coreutils'; then
			echo "$(call fmt_message,[SDK] GNU coreutils verified via mise)"
		else
			echo "$(call fmt_message,[SDK] Installing mise tools...)"
			if mise install; then
				echo "$(call fmt_message,[SDK] Mise tools installed)"
				echo "$(call fmt_tip,Re-run make to use mise-provisioned tools in PATH)"
			else
				$(call shell_fail,Failed to install mise tools)
			fi
		fi
	fi
	touch -t 200001010000 "$@"

# EOF
