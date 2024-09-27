.PHONY: dist-www
run-www: $(RUN_WWW_ALL) ## Runs the local web server
	@$(call rule-pre-cmd)
	if [ -d "deps/extra" ]; then
		PORT=$(PORT) PYTHONPATH=deps/extra/src/py python -m extra
	else
		python -m http.server $(PORT)
	fi
	$(call rule-post-cmd)


.PHONY: dist-www
dist-www: $(DIST_WWW_ALL) ## Builds web assets in $(DIST_WWW_ALL)
	@$(call rule-pre-cmd)

	$(call rule-post-cmd,$(DIST_WWW_ALL))

# =============================================================================
# RUN
# =============================================================================

run/lib/%: src/%
	@$(call rule-pre-cmd)
	ln -sfr "$<" "$@"

run/%: src/html/%
	@$(call rule-pre-cmd)
	ln -sfr "$<" "$@"

run/%: src/xml/%
	@$(call rule-pre-cmd)
	ln -sfr "$<" "$@"

# =============================================================================
# DIST
# =============================================================================

dist/www/%.html: src/xml/%.xml $(SOURCES_XSLT)
	@$(call rule-pre-cmd)
	if ! $$(xsltproc "$<" > "$@.tmp"); then
		unlink "$@.tmp"
		test -e "$@" && unlink "$@"
		exit 1
	else
		mv "$@.tmp" "$@"
	fi

dist/www/lib/js/%.js: src/js/%.js
	@$(call rule-pre-cmd)
	$(call use-cmd,esbuild) --minify --outfile="$@" "$<"

dist/www/lib/css/%.css: src/css/%.css
	@$(call rule-pre-cmd)
	cp -Lp "$<" "$@"

dist/www/lib/css/%.css: src/css/%.js
	@$(call rule-pre-cmd)
	if ! bun -e "import mod from './$<';import css from '@littlecss.js';console.log([...css(mod)].join('\n'))" > "$@"; then
		unlink "$@"
		exit 1
	fi
	# Thanks Claude!
	sed -i '
	# Remove comments
	s!/\*[^*]*\*\+\([^/][^*]*\*\+\)*/!!g
	s!//.*$$!!g

	# Remove newlines and all whitespace around punctuation/brackets
	s/\s*{/{/g
	s/\s*}\s*/}/g
	s/\s*:\s*/:/g
	s/\s*;\s*/;/g
	s/\s*,\s*/,/g

	# Remove trailing semicolon before closing bracket
	s/;}$$/}/g

	# Remove spaces around operators
	s/\s*+\s*/+/g
	s/\s*>\s*/>/g
	s/\s*~\s*/~/g

	# Collapse all remaining whitespace
	s/[[:space:]]\+/ /g

	# Remove leading and trailing spaces
	s/^ //
	s/ $$//
	' "$@"
# EOF
