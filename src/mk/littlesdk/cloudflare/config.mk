## Port on which the Wrangler will run
CLOUDFLARE_WRANGLER_PORT?=8000

## Path to where the Cloudflare Pages to be uploaded are
CLOUDFLARE_PAGES_PATH?=dist/www
CLOUDFLARE_PAGES_ALL?=$(if $(DIST_WWW_ALL),$(DIST_WWW_ALL),$(call file_find,$(CLOUDFLARE_PAGES_PATH),*.*))

## Path to `wrangler`
CLOUDFLARE_WRANGLER?=$(NODE) node_modules/wrangler/bin/wrangler.js
# EOF
