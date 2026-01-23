$(PATH_DIST)/%.sh: src/sh/%.sh
	@$(call rule_pre_cmd)
	mkdir -p $(dir $@)
	cp -a $< $@

# EOF
