.PHONY: prep
prep: $(PREP_ALL) ## Explicitly resolves $(PREP_ALL)
	@

build/install-github-%.task: ## Installs the given Github repo in the form USER@REPO
	@mkdir -p "$(dir $@)"
	USERNAME="$(firstword $(subst @,$(SPACE),$*))"
	REPONAME="$(lastword $(subst @,$(SPACE),$*))"
	mkdir -p deps
	if ! $(GIT) clone "git@github.com:$$USERNAME/$$REPONAME.git" "deps/$$REPONAME"; do
		exit 1
	}
	if [ -e "deps/$$REPONAME/bin/$$REPONAME" ]; then
		mkdir -p run/bin
		ln -sfr "deps/$$REPONAME/bin/$$REPONAME" "run/bin/$$REPONAME"
	fi
	if [ -e "deps/$$REPONAME/src/py/$$REPONAME" ]; then
		mkdir -p run/lib/py
		ln -sfr "deps/$$REPONAME/src/py/$$REPONAME" "run/lib/py/$$REPONAME"
	fi


build/install-python-%.task: ## Installs the given Python module for the given version
	@mkdir -p "$(dir $@)"
	MODULE="$(firstword $(subst @,$(SPACE),$*))"
	VERSION="$(lastword $(subst @,$(SPACE),$*))"
	if [ -n "$$VERSION" ]; then
		MODULE+="--$$VERSION"
	fi
	if $(PYTHON) -m pip install --user -U "$$MODULE"; then
		touch "$@"
	fi

build/install-node-%.task: ## Installs the given Node module
	@mkdir -p "$(dir $@)"
	if $(NPM) install  "$*"; then
		touch "$@"
	fi

# EOF
