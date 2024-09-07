build/install-github-%.task: ## Installs the given Github repo in the form USER@REPO
	@mkdir -p "$(dir $@)"
	var username = "$(firstword $(subst @,$(SPACE),$*))"
	var reponame = "$(lastword $(subst @,$(SPACE),$*))"
	mkdir -p $(PATH_DEPS)
	if ?($(GIT) clone git@github.com:$$username/$$reponame.git deps/$$reponame) {
		exit 1
	}
	if ?(test -e deps/$$reponame/bin/$$reponame) {
		mkdir -p run/bin
		ln -sfr deps/$$reponame/bin/$$reponame run/bin/$$reponame
	}
	if ?(test -e deps/$$reponame/src/py/$$reponame) {
		mkdir -p run/lib/py
		ln -sfr deps/$$reponame/src/py/$$reponame run/lib/py/$$reponame
	}


build/install-python-%.task: ## Installs the given Python module for the given version
	@mkdir -p "$(dir $@)"
	var module = "$(firstword $(subst @,$(SPACE),$*))"
	var version = "$(lastword $(subst @,$(SPACE),$*))"
	$(PYTHON) -m pip install --user -U $$module(if (not (eq $$version "")) {echo "=="$$version})
	touch "$@"

build/install-node-%.task: ## Installs the given Node module
	@mkdir -p "$(dir $@)"
	$(NODE_PACKAGER) install  "$*"
	touch "$@"

# EOF
