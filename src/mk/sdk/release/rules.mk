# -----------------------------------------------------------------------------
#
# RELEASE RULES
#
# -----------------------------------------------------------------------------

# NOTE: Rules are always defined so that `make help` stays accurate; recipes
# validate the configuration instead. This module relies on the JS module for
# the `$(NODE)` runtime, and on the `jj`, `git` and `rsync` CLIs.
#
# The `release` flow assumes a colocated jj+git repository, so that `jj tag
# set` creates a git tag that `git push` can publish, and a working copy that
# only holds the release changes: when the version is bumped, only
# `RELEASE_COMMIT_FILES` are committed, so unrelated pending changes are left
# out of the tagged revision.

# --
# Version

# Returns success when the tag `v$1` already exists.
release_tag_exists=jj tag list -T 'name ++ "\n"' | grep -qx "v$1"

.PHONY: update-version
update-version: $(RELEASE_VERSION_TASK) ## Syncs files derived from PROJECT_VERSION
	@set -eu; \
	test -n "$(strip $(PROJECT_VERSION))" || { echo "$(call fmt_error,[RELEASE] PROJECT_VERSION is not set)"; exit 1; }

# Propagates PROJECT_VERSION to package.json and RELEASE_VERSION_EXTRA targets.
$(PATH_RUN_TASK)/project-version-%.task: $(PROJECT_VERSION_FILE) $(RELEASE_VERSION_FILES)
	@mkdir -p "$(dir $@)"
	@test -n "$(NODE)" || { echo "$(call fmt_error,[RELEASE] the JS module is required for the NODE runtime)"; exit 1; }
	@if [ -f package.json ]; then VERSION="$*" $(NODE) --input-type=module -e 'import fs from "node:fs"; const version=process.env.VERSION; const packageData=JSON.parse(fs.readFileSync("package.json")); packageData.version=version; fs.writeFileSync("package.json", JSON.stringify(packageData, null, "\t")+"\n")'; fi
	@VERSION="$*" $(RELEASE_VERSION_EXTRA)
	@touch "$@"

# --
# Release

.PHONY: release
release: $(RELEASE_VERSION_TASK) $(call use_cli,jj) $(call use_cli,git) ## Tags, pushes and deploys the current revision
	@set -eu; \
	test -n "$(strip $(PROJECT_VERSION))" || { echo "$(call fmt_error,[RELEASE] PROJECT_VERSION is not set)"; exit 1; }; \
	test -n "$(NODE)" || { echo "$(call fmt_error,[RELEASE] the JS module is required for the NODE runtime)"; exit 1; }; \
	echo "$(PROJECT_VERSION)" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$$' || { echo "$(call fmt_error,[RELEASE] PROJECT_VERSION must be MAJOR.MINOR.PATCH)"; exit 1; }; \
	description=$$(jj log --no-graph -r @ -T 'description.first_line()'); \
	if [ -z "$$description" ]; then \
		echo "$(call fmt_error,[RELEASE] current JJ revision has no description)"; \
		exit 1; \
	fi; \
	version="$(PROJECT_VERSION)"; \
	if $(call release_tag_exists,$$version); then \
		IFS=. read -r major minor patch <<< "$$version"; \
		patch=$$((patch + 1)); \
		version="$$major.$$minor.$$patch"; \
		while $(call release_tag_exists,$$version); do \
			patch=$$((patch + 1)); \
			version="$$major.$$minor.$$patch"; \
		done; \
		$(NODE) -e 'const fs=require("fs"), v=process.argv[1], file=process.argv[2]; const config=fs.readFileSync(file,"utf8").replace(/^PROJECT_VERSION[ \t]*[:?]?=.*$$/m,"PROJECT_VERSION:="+v); fs.writeFileSync(file,config); if (fs.existsSync("package.json")) { const packageData=JSON.parse(fs.readFileSync("package.json")); packageData.version=v; fs.writeFileSync("package.json", JSON.stringify(packageData,null,"\t")+"\n"); }' "$$version" "$(PROJECT_VERSION_FILE)"; \
		jj commit $(RELEASE_COMMIT_FILES) -m "[Release] $(PROJECT): version $$version"; \
	else \
		jj commit; \
	fi; \
	release_revision="@-"; \
	$(SDK_MAKE) PROJECT_VERSION="$$version" check; \
	$(SDK_MAKE) PROJECT_VERSION="$$version" test; \
	$(SDK_MAKE) PROJECT_VERSION="$$version" dist; \
	if [ -f package.json ]; then \
		package_version=$$($(NODE) -p "require('./package.json').version"); \
		test "$$package_version" = "$$version"; \
	fi; \
	jj tag set "v$$version" --revision="$$release_revision"; \
	git push $(RELEASE_REMOTE) "v$$version"; \
	$(SDK_MAKE) PROJECT_VERSION="$$version" release-deploy

.PHONY: release-deploy
release-deploy: $(PREP_ALL) $(call use_cli,rsync) ## Publishes RELEASE_DEPLOY_FILES to RELEASE_DEPLOY_URI
	@set -eu; \
	test -n "$(RELEASE_DEPLOY_URI)" || { echo "$(call fmt_error,[RELEASE] RELEASE_DEPLOY_URI is not set)"; exit 1; }; \
	test -n "$(strip $(RELEASE_DEPLOY_FILES))" || { echo "$(call fmt_error,[RELEASE] RELEASE_DEPLOY_FILES is empty)"; exit 1; }; \
	rsync -av --mkpath $(RELEASE_DEPLOY_FILES) "$(RELEASE_DEPLOY_URI)"

# EOF
