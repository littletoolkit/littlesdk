# -----------------------------------------------------------------------------
#
# CLOUDFLARE MODULE RULES
#
# -----------------------------------------------------------------------------

# Rules for Cloudflare Pages deployment and wrangler management.

# -----------------------------------------------------------------------------
#
# DEVELOPMENT SERVER
#
# -----------------------------------------------------------------------------

.PHONY: cloudflare-start-wrangler
cloudflare-start-wrangler: $(PREP_ALL) build/cloudflare-login-wrangler.task ## Starts wrangler dev server
	@# SEE: https://blog.cloudflare.com/10-things-i-love-about-wrangler/
	# NOTE: There's a `dev --local` mode as well
	$(CLOUDFLARE_WRANGLER) dev --ip 0.0.0.0 --port $(CLOUDFLARE_WRANGLER_PORT)

# -----------------------------------------------------------------------------
#
# DEPLOYMENT
#
# -----------------------------------------------------------------------------

.PHONY: cloudflare-deploy-pages
cloudflare-deploy-pages: build/cloudflare-deploy-pages.task ## Deploys to Cloudflare Pages
	@

build/cloudflare-deploy-pages.task: build/cloudflare-login-wrangler.task
	@$(CLOUDFLARE_WRANGLER) pages deploy $(CLOUDFLARE_PAGES_PATH) && touch "$@"

# -----------------------------------------------------------------------------
#
# AUTHENTICATION
#
# -----------------------------------------------------------------------------

build/cloudflare-login-wrangler.task: build/install-node-wrangler.task ## Authenticates with Cloudflare
	@mkdir -p "$(dir $@)"
	$(CLOUDFLARE_WRANGLER) login && touch "$@"

# EOF
