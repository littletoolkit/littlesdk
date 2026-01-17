.PHONY: prep
prep: $(PREP_ALL) ## Explicitly resolves $(PREP_ALL)
	@$(call rule_pre_cmd)

# =============================================================================
# CONFIG
# =============================================================================

# --
# Links configuration files
%: $(PATH_SRC)/etc/%
	@$(call rule_pre_cmd)
	if [ -e "$@" ]; then
		if [ -L "$@" ]; then
			unlink "$@"
		else
			echo "$(call fmt_warn,[SDK] Skipping config file $(call fmt_path,$@): already exists and is not a symlink)"
			exit 0
		fi
	fi
	ln -sfr "$<" "$@"

# --
# Links dotfiles, prefixed with a dot
.%: $(SDK_PATH)/etc/dotfiles/%
	@$(call rule_pre_cmd)
	if [ -e "$@" ]; then
		if [ -L "$@" ]; then
			unlink "$@"
		else
			echo "$(call fmt_warn,[SDK] Skipping dotfile $(call fmt_path,$@): already exists and is not a symlink)"
			exit 0
		fi
	fi
	if [ -d "$<" ]; then
		mkdir -p "$@";
	else
		mkdir -p "$(dir $@)";
		ln -sfr "$<" "$@";
	fi

# EOF
