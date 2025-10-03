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
	ln -sfr "$<" "$@"

# EOF
