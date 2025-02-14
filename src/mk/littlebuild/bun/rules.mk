build/install_tool-bun.task: build/install_tool-bun-$(BUN_VERSION).task
	@$(call rule_pre_cmd)
	touch "$@"

build/install_tool-bun-%.task:
	@$(call rule_pre_cmd)
	# FIXME: This does not seem to work, I get a segfault
	curl -fsSL -o $@.zip https://github.com/oven-sh/bun/releases/$*/download/bun-linux-x64.zip
	mkdir -p "$@.files"
	unzip -j $@.zip  -d "$@.files"
	$(call sh_install_tool,$@.files/bun)

# EOF
