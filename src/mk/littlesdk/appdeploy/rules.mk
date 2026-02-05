# -----------------------------------------------------------------------------
# RULES
# -----------------------------------------------------------------------------

# --
# Copies shell scripts from src/sh/ to dist/
# This rule ensures that all shell scripts defined in APPDEPLOY_SCRIPTS are
# copied to the distribution directory.
$(PATH_DIST)/%.sh: src/sh/%.sh
	@$(call rule_pre_cmd)
	mkdir -p $(dir $@)
	cp -a $< $@

# EOF
