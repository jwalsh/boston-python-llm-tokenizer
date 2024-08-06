# Boston Python LLM Tokenizer Makefile

# ====== Variables ======
POETRY := poetry
PYTHON := $(POETRY) run python
PIP := $(POETRY) run pip
EMACS := emacs
EMACSFLAGS := -Q -l $(PWD)/emacs-config/init.el
EMACSBATCH := $(EMACS) -Q --batch

# ====== Directories ======
DRILLS_DIR := drills
SRC_DIR := src
TESTS_DIR := tests
IMAGES_DIR := images
THUMBS_DIR := $(IMAGES_DIR)/thumbnails
EMACS_DIR := emacs-config

# ====== Marker Files ======
SETUP_MARKER := .setup_complete
CODESPACE_MARKER := .codespace_setup_complete

# ====== Main Targets ======
.DEFAULT_GOAL := help

.PHONY: help setup emacs-setup drill emacs test format typecheck freeze thumbnails clean install-deps update-emacs-packages setup-github-codespace

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: $(SETUP_MARKER) ## Set up the entire project environment (start here)

$(SETUP_MARKER): pyproject.toml
	@echo "Setting up Boston Python LLM Tokenizer environment..."
	@mkdir -p $(DRILLS_DIR) $(SRC_DIR)/boston_python_llm_tokenizer $(IMAGES_DIR) $(THUMBS_DIR)
	@touch $(SRC_DIR)/boston_python_llm_tokenizer/__init__.py
	@$(POETRY) install
	@touch $@
	@echo "Setup complete!"

emacs-setup: $(SETUP_MARKER) ## Set up Emacs configuration
	@echo "Setting up Emacs configuration..."
	@mkdir -p $(EMACS_DIR)
	@if [ ! -f $(EMACS_DIR)/init.el ] || ! cmp -s emacs-config/init.el $(EMACS_DIR)/init.el; then \
		cp emacs-config/init.el $(EMACS_DIR)/init.el && \
		echo "Copied init.el to $(EMACS_DIR)"; \
	else \
		echo "init.el is already up to date in $(EMACS_DIR)"; \
	fi
	@echo "Installing Emacs packages..."
	@$(EMACSBATCH) -l $(EMACS_DIR)/init.el \
		--eval "(progn \
			(require 'package) \
			(package-refresh-contents) \
			(dolist (package package-selected-packages) \
				(unless (package-installed-p package) \
					(package-install package))))" \
		2>&1 | tee emacs_setup.log
	@echo "Emacs configuration complete! Check emacs_setup.log for details."

drill: $(SETUP_MARKER) ## Open the tokenization drill in Emacs
	@$(POETRY) run $(EMACS) $(EMACSFLAGS) --eval '(progn (find-file "$(DRILLS_DIR)/tokenization-drill.org") (org-drill))'

emacs: $(SETUP_MARKER) ## Open Emacs with the custom configuration
	@$(POETRY) run $(EMACS) $(EMACSFLAGS) $(PWD)

test: $(SETUP_MARKER) ## Run tests for Python code
	@$(POETRY) run pytest $(TESTS_DIR)

format: $(SETUP_MARKER) ## Format Python code using Black
	@$(POETRY) run black $(SRC_DIR) $(TESTS_DIR)

typecheck: $(SETUP_MARKER) ## Run type checking on Python code using mypy
	@$(POETRY) run mypy $(SRC_DIR)

freeze: $(SETUP_MARKER) ## Export dependencies to requirements.txt
	@$(POETRY) export -f requirements.txt --output requirements.txt

thumbnails: $(SETUP_MARKER) ## Create thumbnails for JPEG images in the images directory
	@echo "Creating thumbnails..."
	@mkdir -p $(THUMBS_DIR)
	@for img in $(IMAGES_DIR)/*.{jpg,jpeg}; do \
		if [ -f "$$img" ]; then \
			base=$$(basename "$$img" | sed 's/\.[^.]*$$//'); \
			$(POETRY) run convert -geometry 480x480 "$$img" "$(THUMBS_DIR)/$$base-thumb.png"; \
			echo "Created thumbnail for $$img"; \
		fi; \
	done
	@echo "Thumbnail creation complete!"

clean: ## Clean up the environment
	@echo "Cleaning up..."
	@$(POETRY) env remove --all
	@rm -rf $(THUMBS_DIR) $(SETUP_MARKER) $(CODESPACE_MARKER)
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "Cleanup complete!"

install-deps: $(SETUP_MARKER) ## Install project dependencies
	@echo "Installing project dependencies..."
	@$(POETRY) install
	@echo "Dependencies installed."

update-emacs-packages: $(SETUP_MARKER) ## Update Emacs packages
	@echo "Updating Emacs packages..."
	@$(EMACSBATCH) -l $(EMACS_DIR)/init.el \
		--eval "(progn \
			(require 'package) \
			(package-refresh-contents) \
			(dolist (package package-selected-packages) \
				(when (package-installed-p package) \
					(package-install package))))" \
		2>&1 | tee emacs_update.log
	@echo "Emacs packages updated. Check emacs_update.log for details."

setup-github-codespace: $(CODESPACE_MARKER) ## (Optional) Set up GitHub Codespace with Poetry

$(CODESPACE_MARKER):
	@echo "Setting up GitHub Codespace..."
	@if ! command -v poetry &> /dev/null; then \
		echo "Installing Poetry..."; \
		curl -sSL https://install.python-poetry.org | python3 -; \
	fi
	@poetry --version
	@poetry config virtualenvs.in-project true
	@poetry install
	@touch $@
	@echo "GitHub Codespace setup complete!"