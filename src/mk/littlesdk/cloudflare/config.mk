# -----------------------------------------------------------------------------
#
# CLOUDFLARE MODULE CONFIGURATION
#
# -----------------------------------------------------------------------------

# Configuration for Cloudflare deployment and wrangler integration.

# -----------------------------------------------------------------------------
#
# WRANGLER SETTINGS
#
# -----------------------------------------------------------------------------

# --
# ## Server Configuration

# Port for wrangler dev server
CLOUDFLARE_WRANGLER_PORT?=8000 ## Wrangler dev server port

# --
# ## Pages Deployment

# Path to Cloudflare Pages assets for deployment
CLOUDFLARE_PAGES_PATH?=dist/www ## Pages content directory

# All files to deploy to Cloudflare Pages
CLOUDFLARE_PAGES_ALL?=$(if $(DIST_WWW_ALL),$(DIST_WWW_ALL),$(call file_find,$(CLOUDFLARE_PAGES_PATH),*.*)) ## Pages files to deploy

# --
# ## Tools

# Path to wrangler CLI
CLOUDFLARE_WRANGLER?=$(NODE) node_modules/wrangler/bin/wrangler.js ## Wrangler executable path

# EOF
