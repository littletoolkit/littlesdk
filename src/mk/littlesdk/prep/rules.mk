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
define prep-link-dotfile
$(EOL)
.$(1): $(SDK_PATH)/etc/dotfiles/$(1)
	@$$(call rule_pre_cmd)
	if [ -e "$$@" ]; then
		if [ -L "$$@" ]; then
			unlink "$$@"
		else
			echo "$(call fmt_warn,[SDK] Skipping dotfile $(call fmt_path,$$@): already exists and is not a symlink)"
			exit 0
		fi
	fi
	if [ -d "$$<" ]; then
		mkdir -p "$$@";
	else
		mkdir -p "$$(dir $$@)";
		ln -sfr "$$<" "$$@";
	fi
$(EOL)
endef

# We can't use `.%: $(SDK_PATH)/etc/dotfiles/%` because make will only match
# a filename as there's no slash in the target.
$(foreach F,$(SOURCES_DOTFILES),$(eval $(call prep-link-dotfile,$(patsubst $(SDK_PATH)/etc/dotfiles/%,%,$F))))

# EOF
