.PHONY: prep
prep: $(PREP_ALL) ## Explicitly resolves $(PREP_ALL)
	@$(call rule_pre_cmd)

build/install_tool-bun.task: build/install_tool-bun-latest.task
	@$(call rule_pre_cmd)
	touch "$@"

build/install_tool-bun-%.task:
	@$(call rule_pre_cmd)
	# FIXME: This does not seem to work, I get a segfault
	curl -fsSL -o $@.zip https://github.com/oven-sh/bun/releases/$*/download/bun-linux-x64.zip
	mkdir -p "$@.files"
	unzip -j $@.zip  -d "$@.files"
	$(call install_tool,$@.files/bun)

build/install-github-%.task: ## Installs the given Github repo in the form USER/REPO@VERSION
	@$(call rule_pre_cmd)
	USERNAME="$(firstword $(subst /,$(SPACE),$*))"
	REPONAME="$(firstword $(subst @,$(SPACE),$(lastword $(subst /,$(SPACE),$*))))"
	REVISION="$(lastword  $(subst @,$(SPACE),$(lastword $(subst /,$(SPACE),$*))))"
	mkdir -p deps
	if [ ! -e "deps/$$REPONAME" ]; then
		if ! $(GIT) clone "git@github.com:$$USERNAME/$$REPONAME.git" "deps/$$REPONAME"; then
			echo "$(call fmt_error,Unable to install Github repository: $*)"
			test -e "$@" && unlink "$@"
			exit 1
		fi
	fi
	if [ ! -e "$@" ]; then touch "$@"; fi
	if [ -e "deps/$$REPONAME/bin/$$REPONAME" ]; then
		mkdir -p run/bin
		ln -sfr "deps/$$REPONAME/bin/$$REPONAME" "run/bin/$$REPONAME"
	fi
	if [ -e "deps/$$REPONAME/src/py/$$REPONAME" ]; then
		mkdir -p run/lib/py
		ln -sfr "deps/$$REPONAME/src/py/$$REPONAME" "run/lib/py/$$REPONAME"
	fi


build/install-python-%.task: ## Installs the given Python module for the given version
	@$(call rule_pre_cmd)
	MODULE="$(firstword $(subst @,$(SPACE),$*))"
	VERSION="$(lastword $(subst @,$(SPACE),$*))"
	if [ -n "$$VERSION" ]; then
		MODULE+="--$$VERSION"
	fi
	if $(PYTHON) -m pip install --user -U "$$MODULE"; then
		touch "$@"
	else
		echo "$(call fmt_error,Unable to install Python module: $$MODULE)"
		test -e "$@" && unlink "$@"
		exit 1
	fi

build/install-node-%.task: ## Installs the given Node module
	@$(call rule_pre_cmd)
	if $(NPM) install  "$*"; then
		touch "$@"
	else
		echo "$(call fmt_error,Unable to install Node module: $*)"
		test -e "$@" && unlink "$@"
		exit 1
	fi

# =============================================================================
# CONFIG
# =============================================================================

%: src/etc/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

# EOF
