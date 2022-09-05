default: help

.PHONY: create_tarball
create_tarball: ## Create a tarball from local repository
	@tar \
	--exclude='./.git' \
	--exclude='./.github' \
	--exclude='test_data/' \
	--exclude='*_test_kit*' \
	--exclude='*_test*' \
	--exclude='docs-site/' \
	--exclude='formula.rb' \
	--exclude='git-deps-syncer.tar.gz' \
	-zcf git-deps-syncer.tar.gz \
	.

.PHONY: install_from_respository
install_from_respository: create_tarball ## Install a local git-deps-syncer from this repository
	@LOCAL_ARCHIVE_FILEPATH=$(CURDIR)/git-deps-syncer.tar.gz ./install.sh
	@rm -rf $(CURDIR)/git-deps-syncer.tar.gz

.PHONY: uninstall
uninstall: ## Uninstall a local git-deps-syncer
	@./uninstall.sh

.PHONY: release_version_create
release_version_create: create_tarball ## Create release tag in GitHub with version from resources/version.txt
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/release.sh' \
	'action: create' \
	'version_file_path: ./resources/version.txt' \
	'artifact_file_path: git-deps-syncer.tar.gz' \
	'debug'"
	@rm -rf $(CURDIR)/git-deps-syncer.tar.gz

.PHONY: release_version_delete
release_version_delete: ## Enter a tag to delete its attached release tag from GitHub
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/release.sh' \
	'action: delete' \
	'debug'"

.PHONY: calculate_sha_by_commit_hash
calculate_sha_by_commit_hash: ## Enter a commit to get its SHA hash
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/sha_calculator.sh' \
	'sha_source: commit-hash' \
	'repository_url: https://github.com/ZachiNachshon/git-deps-syncer'"

.PHONY: calculate_sha_by_tag
calculate_sha_by_tag: ## Enter a tag to get its SHA hash
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/github/sha_calculator.sh' \
	'sha_source: tag' \
	'repository_url: https://github.com/ZachiNachshon/git-deps-syncer' \
	'asset_name: git-deps-syncer.tar.gz'"

# http://localhost:9001/git-deps-syncer/
.PHONY: serve_docs_site
serve_docs_site: ## Run a local docs site
	@cd docs-site && npm run docs-serve

# http://192.168.x.xx:9001/
.PHONY: serve_docs_site_lan
serve_docs_site_lan: ## Run a local docs site (open for LAN)
	@cd docs-site && npm run docs-serve-lan

.PHONY: test
test: ## Run tests suite
	@sh -c "$(CURDIR)/git-deps-syncer_test.sh"

.PHONY: fmt
fmt: ## Format shell scripts using shfmt bash style (https://github.com/mvdan/sh)
	@sh -c "'$(CURDIR)/external/shell_scripts_lib/runner/shfmt/shfmt.sh' \
  		'working_dir: $(CURDIR)' \
  		'shfmt_args: -w -ci -i=2 -ln=bash $(CURDIR)' \
  		'debug'"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


