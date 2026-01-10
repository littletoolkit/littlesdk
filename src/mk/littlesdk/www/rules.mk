.PHONY: www-run
www-run: $(WWW_RUN_ALL) ## Runs the local web server
	@$(call rule_pre_cmd)
	if [ -d "deps/extra" ]; then
		$(if $(WWW_PATH),env -C "$(WWW_PATH)") PORT=$(PORT) PYTHONPATH=$(realpath deps/extra/src/py) $(PYTHON) -m extra
	else
		$(if $(WWW_PATH),env -C "$(WWW_PATH)") $(PYTHON) -m http.server $(PORT)
	fi
	$(call rule_post_cmd)


.PHONY: www-build
www-build: $(WWW_BUILD_ALL) ## Builds www assets in $(WWW_BUILD_ALL)
	@$(call rule_pre_cmd)
	$(call rule_post_cmd,$(WWW_BUILD_ALL))

.PHONY: www-dist
www-dist: $(WWW_DIST_ALL) ## Distributes www assets to $(WWW_DIST_ALL)
	@$(call rule_pre_cmd)
	$(call rule_post_cmd,$(WWW_DIST_ALL))

# =============================================================================
# BUILD
# =============================================================================

# HTML: Tidy src/html/*.html to build/html/*.html
# Exit code 0 = success, 1 = warnings (OK), >1 = errors (fail)
$(PATH_BUILD)/html/%.html: $(PATH_SRC)/html/%.html
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	@if $(HTMLTIDY) -q -o "$@" "$<"; then \
		true; \
	elif [ $$? -eq 1 ]; then \
		true; \
	else \
		rm -f "$@"; \
		exit 1; \
	fi

# XML: Transform to HTML via xsltproc
$(PATH_BUILD)/xml/%.html: $(PATH_SRC)/xml/%.xml $(SOURCES_XSLT)
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	@if ! xsltproc "$<" > "$@.tmp"; then \
		rm -f "$@.tmp"; \
		rm -f "$@"; \
		exit 1; \
	else \
		mv "$@.tmp" "$@"; \
	fi

# CSS from JS: Compile CSS from src/css/*.js to build/css/*.css
$(PATH_BUILD)/css/%.css: $(PATH_SRC)/css/%.js
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	@if ! $(BUN) -e "import mod from './$<';import css from '@littlecss.js';console.log([...css(mod)].join('\n'))" > "$@"; then \
		rm -f "$@"; \
		exit 1; \
	fi

# =============================================================================
# RUN
# =============================================================================

run/lib/%: src/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

run/lib/%: build/lib/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

run/%: src/html/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

run/%: src/xml/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

# =============================================================================
# DIST
# =============================================================================

# HTML: Copy tidied HTML from build/html to dist/www
$(PATH_DIST)/www/%.html: $(PATH_BUILD)/html/%.html
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# XML: Copy transformed HTML from build/xml to dist/www
$(PATH_DIST)/www/%.html: $(PATH_BUILD)/xml/%.html
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# JS: Copy from JS module build outputs (build/lib/js) to dist/www/lib/js
$(PATH_DIST)/www/lib/js/%.js: $(JS_BUILD_PATH)/%.js
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# CSS: Copy from src/css to dist/www/lib/css
$(PATH_DIST)/www/lib/css/%.css: $(PATH_SRC)/css/%.css
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# CSS from JS: Copy compiled CSS from build/css to dist/www/lib/css
$(PATH_DIST)/www/lib/css/%.css: $(PATH_BUILD)/css/%.css
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# JSON: Copy from src/json to dist/www/lib/json
$(PATH_DIST)/www/lib/json/%.json: $(PATH_SRC)/json/%.json
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# Data: Copy from src/data to dist/www/data (preserve structure)
$(PATH_DIST)/www/data/%: $(PATH_SRC)/data/%
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# Static: Copy from src/static to dist/www/static (preserve structure)
$(PATH_DIST)/www/static/%: $(PATH_SRC)/static/%
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# =============================================================================
# BUNDLE (Standalone production build)
# =============================================================================

# Compile LittleCSS to static CSS
$(WWW_BUNDLE_LITTLECSS): $(wildcard $(PATH_DEPS)/littlecss/src/css/*.js)
	@$(call rule_pre_cmd)
	@mkdir -p $(dir $@)
	$(call shell_create_if,$(PATH_DEPS)/littlecss/bin/littlecss $(PATH_DEPS)/littlecss/src/css/all.js > $@,Unable to compile LittleCSS)

# Copy project CSS to dist/www
$(WWW_BUNDLE_CSS): $(PATH_SRC)/css/style.css
	@$(call rule_pre_cmd)
	@mkdir -p $(dir $@)
	cp -Lp "$<" "$@"

# Generate production index.html from source (when JS_BUNDLE_ENTRY is set)
# - Remove import map
# - Remove inline module scripts (both in head and body)
# - Remove highlight.js CDN (unused)
# - Remove iconify CDN (bundled in JS)
# - Update CSS paths (use ./ for portability when not served from root)
# - Add littlecss.css and bundle script
$(WWW_BUNDLE_INDEX): $(PATH_SRC)/html/index.html $(JS_BUNDLE_OUTPUT) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS)
	@$(call rule_pre_cmd)
	@mkdir -p $(dir $@)
	sed -e '/<script type="importmap">/,/<\/script>/d' \
	    -e '/<script type="module">/,/<\/script>/d' \
	    -e 's|<link href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js[^>]*>||g' \
	    -e 's|<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js[^>]*></script>||g' \
	    -e 's|<script src="https://cdn.jsdelivr.net/npm/iconify-icon[^>]*></script>||g' \
	    -e 's|<link href="/src/css/style.css"|<link href="./style.css"|' \
	    -e 's|</head>|<link href="./littlecss.css" rel="stylesheet" type="text/css" />\n  <script type="module" src="./$(PROJECT).min.js"></script>\n  </head>|' \
	    "$<" > "$@"

.PHONY: www-bundle
www-bundle: $(JS_BUNDLE_OUTPUT) $(WWW_BUNDLE_INDEX) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS) ## Builds standalone production bundle
	@$(call rule_pre_cmd)
	$(call rule_post_cmd,$(JS_BUNDLE_OUTPUT) $(WWW_BUNDLE_INDEX) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS))

# Generate debug index.html (references non-minified bundle)
$(WWW_BUNDLE_DEBUG_INDEX): $(PATH_SRC)/html/index.html $(JS_BUNDLE_DEBUG_OUTPUT) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS)
	@$(call rule_pre_cmd)
	@mkdir -p $(dir $@)
	sed -e '/<script type="importmap">/,/<\/script>/d' \
	    -e '/<script type="module">/,/<\/script>/d' \
	    -e 's|<link href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js[^>]*>||g' \
	    -e 's|<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js[^>]*></script>||g' \
	    -e 's|<script src="https://cdn.jsdelivr.net/npm/iconify-icon[^>]*></script>||g' \
	    -e 's|<link href="/src/css/style.css"|<link href="./style.css"|' \
	    -e 's|</head>|<link href="./littlecss.css" rel="stylesheet" type="text/css" />\n  <script type="module" src="./$(PROJECT).js"></script>\n  </head>|' \
	    "$<" > "$@"

.PHONY: www-bundle-debug
www-bundle-debug: $(JS_BUNDLE_DEBUG_OUTPUT) $(WWW_BUNDLE_DEBUG_INDEX) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS) ## Builds standalone debug bundle (non-minified)
	@$(call rule_pre_cmd)
	$(call rule_post_cmd,$(JS_BUNDLE_DEBUG_OUTPUT) $(WWW_BUNDLE_DEBUG_INDEX) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS))

# EOF
