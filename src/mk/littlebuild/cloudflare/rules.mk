.PHONY: cloudflare-start-wrangler
cloudflare-start-wrangler: $(PREP_ALL) build/cloudflare-login-wrangler.task ## Starts the wrangler server
	@# SEE: https://blog.cloudflare.com/10-things-i-love-about-wrangler/
	# NOTE: There's a `dev --local` mode as well
	$(CLOUDFLARE_WRANGLER) dev --ip 0.0.0.0 --port $(CLOUDFLARE_WRANGLER_PORT)

.PHONY: cloudflare-deploy-pages
cloudflare-deploy-pages: build/cloudflare-deploy-pages.task ## Deploys Cloudlare pages
	@

build/cloudflare-deploy-pages.task: build/cloudflare-login-wrangler.task
	@$(CLOUDFLARE_WRANGLER) pages deploy $(CLOUDFLARE_PAGES_PATH)  && touch "$@"

build/cloudflare-login-wrangler.task: build/install-node-wrangler.task ## DEV: Installs and login Wrangler
	@mkdir -p "$(dir $@)"
	$(CLOUDFLARE_WRANGLER) login  && touch "$@"

# EOF
