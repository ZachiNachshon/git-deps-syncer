default: help

.PHONY: release
release: ## Create release tag in GitHub with version from resources/version.txt
	@sh -c "'$(CURDIR)/scripts/release.sh' --create"

.PHONY: delete-release
delete-release: ## Enter a tag to delete its attached release tag from GitHub
	@sh -c "'$(CURDIR)/scripts/release.sh' --delete"

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


