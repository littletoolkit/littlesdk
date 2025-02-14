.PHONY: prep

prep: $(PREP_ALL) ## Explicitly resolves $(PREP_ALL)
	@$(call rule_pre_cmd)

# =============================================================================
# CONFIG
# =============================================================================

%: src/etc/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

# EOF
