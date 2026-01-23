# -----------------------------------------------------------------------------
# RULES
# -----------------------------------------------------------------------------

# --
# Runs the local web server
# This rule starts a local web server to serve the web assets.
.PHONY: www-run
www-run: $(WWW_RUN_ALL) ## Runs the local web server
	@$(call rule_pre_cmd)
	if [ -d "deps/extra" ]; then
		$(if $(WWW_PATH),env -C "$(WWW_PATH)") PORT=$(PORT) PYTHONPATH=$(realpath deps/extra/src/py) $(PYTHON) -m extra
	else
		$(if $(WWW_PATH),env -C "$(WWW_PATH)") $(PYTHON) -m http.server $(PORT)
	fi
	$(call rule_post_cmd)


# --
# Builds www assets
# This rule builds all the web assets defined in WWW_BUILD_ALL.
.PHONY: www-build
www-build: $(WWW_BUILD_ALL) ## Builds www assets in $(WWW_BUILD_ALL)
	@$(call rule_pre_cmd)
	$(call rule_post_cmd,$(WWW_BUILD_ALL))

# --
# Distributes www assets
# This rule distributes all the web assets defined in WWW_DIST_ALL.
.PHONY: www-dist
www-dist: $(WWW_DIST_ALL) ## Distributes www assets to $(WWW_DIST_ALL)
	@$(call rule_pre_cmd)
	$(call rule_post_cmd,$(WWW_DIST_ALL))

# =============================================================================
# BUILD
# =============================================================================

# --
# HTML: Tidy src/html/*.html to build/html/*.html
# Exit code 0 = success, 1 = warnings (OK), >1 = errors (fail)
# This rule tidies HTML files using HTMLTIDY and places them in the build directory.
$(PATH_BUILD)/html/%.html: $(PATH_SRC)/html/%.html
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	@$(call sh_check_defined,HTMLTIDY)
	@if $(HTMLTIDY) -q -o "$@" "$<"; then \
		true; \
	elif [ $$? -eq 1 ]; then \
		true; \
	else \
		rm -f "$@"; \
		exit 1; \
	fi

# --
# XML: Transform to HTML via xsltproc
# This rule transforms XML files to HTML using xsltproc and places them in the build directory.
$(PATH_BUILD)/xml/%.html: $(PATH_SRC)/xml/%.xml $(SOURCES_XSLT)
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	@$(call sh_check_exists,$<)
	@if ! xsltproc "$<" > "$@.tmp"; then \
		rm -f "$@.tmp"; \
		rm -f "$@"; \
		exit 1; \
	else \
		mv "$@.tmp" "$@"; \
	fi

# --
# CSS from JS: Compile CSS from src/css/*.js to build/css/*.css
# This rule compiles CSS from JavaScript files using Bun and places them in the build directory.
$(PATH_BUILD)/css/%.css: $(PATH_SRC)/css/%.js
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	@$(call sh_check_defined,BUN)
	@if ! $(BUN) -e "import mod from './$<';import css from '@littlecss.js';console.log([...css(mod)].join('\n'))" > "$@"; then \
		rm -f "$@"; \
		exit 1; \
	fi

# =============================================================================
# RUN
# =============================================================================

# --
# Links source files to run/lib/
# This rule creates symbolic links from source files to the run directory.
run/lib/%: src/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

# --
# Links build files to run/lib/
# This rule creates symbolic links from build files to the run directory.
run/lib/%: build/lib/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

# --
# Links HTML files to run/
# This rule creates symbolic links from HTML files to the run directory.
run/%: src/html/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

# --
# Links XML files to run/
# This rule creates symbolic links from XML files to the run directory.
run/%: src/xml/%
	@$(call rule_pre_cmd)
	ln -sfr "$<" "$@"

# =============================================================================
# DIST
# =============================================================================

# --
# HTML: Copy tidied HTML from build/html to dist/www
# This rule copies tidied HTML files from the build directory to the distribution directory.
$(PATH_DIST)/www/%.html: $(PATH_BUILD)/html/%.html
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# --
# XML: Copy transformed HTML from build/xml to dist/www
# This rule copies transformed HTML files from the build directory to the distribution directory.
$(PATH_DIST)/www/%.html: $(PATH_BUILD)/xml/%.html
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# --
# JS: Copy from JS module build outputs (build/lib/js) to dist/www/lib/js
# This rule copies JavaScript files from the build directory to the distribution directory.
$(PATH_DIST)/www/lib/js/%.js: $(JS_BUILD_PATH)/%.js
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# --
# CSS: Copy from src/css to dist/www/lib/css
# This rule copies CSS files from the source directory to the distribution directory.
$(PATH_DIST)/www/lib/css/%.css: $(PATH_SRC)/css/%.css
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# --
# CSS from JS: Copy compiled CSS from build/css to dist/www/lib/css
# This rule copies compiled CSS files from the build directory to the distribution directory.
$(PATH_DIST)/www/lib/css/%.css: $(PATH_BUILD)/css/%.css
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# --
# JSON: Copy from src/json to dist/www/lib/json
# This rule copies JSON files from the source directory to the distribution directory.
$(PATH_DIST)/www/lib/json/%.json: $(PATH_SRC)/json/%.json
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# --
# Data: Copy from src/data to dist/www/data (preserve structure)
# This rule copies data files from the source directory to the distribution directory.
$(PATH_DIST)/www/data/%: $(PATH_SRC)/data/%
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# --
# Static: Copy from src/static to dist/www/static (preserve structure)
# This rule copies static files from the source directory to the distribution directory.
$(PATH_DIST)/www/static/%: $(PATH_SRC)/static/%
	@$(call rule_pre_cmd)
	@mkdir -p "$(dir $@)"
	cp -Lp "$<" "$@"

# =============================================================================
# BUNDLE (Standalone production build)
# =============================================================================

# --
# Compile LittleCSS to static CSS
# This rule compiles LittleCSS to a static CSS file.
$(WWW_BUNDLE_LITTLECSS): $(wildcard $(PATH_DEPS)/littlecss/src/css/*.js)
	@$(call rule_pre_cmd)
	@mkdir -p $(dir $@)
	$(call shell_create_if,$(PATH_DEPS)/littlecss/bin/littlecss $(PATH_DEPS)/littlecss/src/css/all.js > $@,Unable to compile LittleCSS)

# --
# Copy project CSS to dist/www
# This rule copies the project CSS file to the distribution directory.
$(WWW_BUNDLE_CSS): $(PATH_SRC)/css/style.css
	@$(call rule_pre_cmd)
	@mkdir -p $(dir $@)
	cp -Lp "$<" "$@"

# --
# Generate production index.html from source (when JS_BUNDLE_ENTRY is set)
# - Remove import map
# - Remove inline module scripts (both in head and body)
# - Remove highlight.js CDN (unused)
# - Remove iconify CDN (bundled in JS)
# - Update CSS paths (use ./ for portability when not served from root)
# - Add littlecss.css and bundle script
# This rule generates a production-ready index.html file.
$(WWW_BUNDLE_INDEX): $(PATH_SRC)/html/index.html $(JS_BUNDLE_OUTPUT) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS)
	@$(call rule_pre_cmd)
	@mkdir -p $(dir $@)
	sed -e '/<script type="importmap">/,/<\/script>/d' \
	    -e '/<script type="module">/,/<\/script>/d' \
	    -e 's|<link href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js[^"]*>||g' \
	    -e 's|<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js[^"]*></script>||g' \
	    -e 's|<script src="https://cdn.jsdelivr.net/npm/iconify-icon[^"]*></script>||g' \
	    -e 's|<link href="/src/css/style.css"|<link href="./style.css"|' \
	    -e 's|</head>|<link href="./littlecss.css" rel="stylesheet" type="text/css" />\n  <script type="module" src="./$(PROJECT).min.js"></script>\n  </head>|' \
	    "$<" > "$@"

# --
# Builds standalone production bundle
# This rule builds a standalone production bundle.
.PHONY: www-bundle
www-bundle: $(JS_BUNDLE_OUTPUT) $(WWW_BUNDLE_INDEX) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS) ## Builds standalone production bundle
	@$(call rule_pre_cmd)
	$(call rule_post_cmd,$(JS_BUNDLE_OUTPUT) $(WWW_BUNDLE_INDEX) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS))

# --
# Generate debug index.html (references non-minified bundle)
# This rule generates a debug index.html file.
$(WWW_BUNDLE_DEBUG_INDEX): $(PATH_SRC)/html/index.html $(JS_BUNDLE_DEBUG_OUTPUT) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS)
	@$(call rule_pre_cmd)
	@mkdir -p $(dir $@)
	sed -e '/<script type="importmap">/,/<\/script>/d' \
	    -e '/<script type="module">/,/<\/script>/d' \
	    -e 's|<link href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js[^"]*>||g' \
	    -e 's|<script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js[^"]*></script>||g' \
	    -e 's|<script src="https://cdn.jsdelivr.net/npm/iconify-icon[^"]*></script>||g' \
	    -e 's|<link href="/src/css/style.css"|<link href="./style.css"|' \
	    -e 's|</head>|<link href="./littlecss.css" rel="stylesheet" type="text/css" />\n  <script type="module" src="./$(PROJECT).js"></script>\n  </head>|' \
	    "$<" > "$@"

# --
# Builds standalone debug bundle (non-minified)
# This rule builds a standalone debug bundle.
.PHONY: www-bundle-debug
www-bundle-debug: $(JS_BUNDLE_DEBUG_OUTPUT) $(WWW_BUNDLE_DEBUG_INDEX) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS) ## Builds standalone debug bundle (non-minified)
	@$(call rule_pre_cmd)
	$(call rule_post_cmd,$(JS_BUNDLE_DEBUG_OUTPUT) $(WWW_BUNDLE_DEBUG_INDEX) $(WWW_BUNDLE_LITTLECSS) $(WWW_BUNDLE_CSS))

# EOF
