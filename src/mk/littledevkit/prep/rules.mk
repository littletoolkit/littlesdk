.PHONY: prep
prep: $(PREP_ALL) ## Explicitly resolves $(PREP_ALL)
	@$(call rule-pre-cmd)

build/install-github-%.task: ## Installs the given Github repo in the form USER/REPO@VERSION
	@$(call rule-pre-cmd)
	USERNAME="$(firstword $(subst /,$(SPACE),$*))"
	REPONAME="$(firstword $(subst @,$(SPACE),$(lastword $(subst /,$(SPACE),$*))))"
	REVISION="$(lastword  $(subst @,$(SPACE),$(lastword $(subst /,$(SPACE),$*))))"
	mkdir -p deps
	if [ ! -e "deps/$$REPONAME" ]; then
		if ! $(GIT) clone "git@github.com:$$USERNAME/$$REPONAME.git" "deps/$$REPONAME"; then
			echo "$(call fmt-error,Unable to install Github repository: $*)"
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
	@$(call rule-pre-cmd)
	MODULE="$(firstword $(subst @,$(SPACE),$*))"
	VERSION="$(lastword $(subst @,$(SPACE),$*))"
	if [ -n "$$VERSION" ]; then
		MODULE+="--$$VERSION"
	fi
	if $(PYTHON) -m pip install --user -U "$$MODULE"; then
		touch "$@"
	else
		echo "$(call fmt-error,Unable to install Python module: $$MODULE)"
		test -e "$@" && unlink "$@"
		exit 1
	fi

build/install-node-%.task: ## Installs the given Node module
	@$(call rule-pre-cmd)
	if $(NPM) install  "$*"; then
		touch "$@"
	else
		echo "$(call fmt-error,Unable to install Node module: $*)"
		test -e "$@" && unlink "$@"
		exit 1
	fi

# =============================================================================
# CONFIG
# =============================================================================

%: src/etc/%
	@$(call rule-pre-cmd)
	ln -sfr "$<" "$@"

# EOF
