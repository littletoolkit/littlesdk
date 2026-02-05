# -----------------------------------------------------------------------------
#
# APPDEPLOY MODULE RULES
#
# -----------------------------------------------------------------------------

# Rules for deploying shell scripts to the distribution directory.

# -----------------------------------------------------------------------------
#
# SCRIPT DISTRIBUTION
#
# -----------------------------------------------------------------------------

# Copies shell scripts from src/sh/ to dist/
$(PATH_DIST)/%.sh: src/sh/%.sh
	@$(call rule_pre_cmd)
	mkdir -p $(dir $@)
	cp -a $< $@

# EOF
