# Variables
PYTHON = python3
PIP = pip3
VENV = .venv
BIN = $(VENV)/bin
ACTIVATE = . $(BIN)/activate
EMACS = emacs
EMACSFLAGS = -Q -l $(PWD)/emacs-config/init.el
EMACSBATCH = $(EMACS) -Q --batch

# Directories
DRILLS_DIR = drills
SRC_DIR = src
TESTS_DIR = tests
IMAGES_DIR = images
THUMBS_DIR = $(IMAGES_DIR)/thumbnails
EMACS_DIR = emacs-config

# Make help the default goal
.DEFAULT_GOAL := help

# Targets
.PHONY: help setup venv emacs-setup drill emacs test format typecheck freeze thumbnails clean

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: venv emacs-setup ## Set up the entire project environment (start here)
	@echo "Setting up Boston Python LLM Tokenizer environment..."
	@mkdir -p $(DRILLS_DIR)
	@mkdir -p $(SRC_DIR)
	@mkdir -p $(IMAGES_DIR)
	@mkdir -p $(THUMBS_DIR)
	@echo "Setup complete!"
	@echo "To activate the virtual environment, run: source $(VENV)/bin/activate"

venv: ## (optional) Create and set up virtual environment
	@echo "Creating virtual environment..."
	@$(PYTHON) -m venv $(VENV)
	@$(ACTIVATE) && $(PIP) install --upgrade pip
	@$(ACTIVATE) && $(PIP) install -r requirements.txt
	@echo "Virtual environment created and packages installed."

EMACS_RETRY = 3
EMACS_RETRY_DELAY = 5

emacs-setup: ## Set up Emacs configuration
	@echo "Setting up Emacs configuration..."
	@mkdir -p $(EMACS_DIR)
	@if [ ! -f $(EMACS_DIR)/init.el ] || ! cmp -s emacs-config/init.el $(EMACS_DIR)/init.el; then \
		cp emacs-config/init.el $(EMACS_DIR)/init.el && \
		echo "Copied init.el to $(EMACS_DIR)"; \
	else \
		echo "init.el is already up to date in $(EMACS_DIR)"; \
	fi
	@echo "Refreshing package contents and installing packages..."
	@for i in $$(seq 1 $(EMACS_RETRY)); do \
		if $(EMACSBATCH) -l $(EMACS_DIR)/init.el \
			--eval "(progn \
				(setq debug-on-error t) \
				(package-refresh-contents) \
				(package-install-selected-packages))" \
			2>&1 | tee emacs_setup.log; then \
			echo "Emacs package installation successful."; \
			break; \
		else \
			echo "Attempt $$i failed. Retrying in $(EMACS_RETRY_DELAY) seconds..."; \
			sleep $(EMACS_RETRY_DELAY); \
		fi; \
		if [ $$i -eq $(EMACS_RETRY) ]; then \
			echo "Emacs package installation failed after $(EMACS_RETRY) attempts."; \
			echo "Please check emacs_setup.log for details."; \
			exit 1; \
		fi; \
	done
	@echo "Emacs configuration complete!"

update-emacs-packages: ## Update Emacs packages
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

drill: venv emacs-setup ## Open the tokenization drill in Emacs
	@$(ACTIVATE) && $(EMACS) $(EMACSFLAGS) --eval '(progn (find-file "$(DRILLS_DIR)/tokenization-drill.org") (org-drill))'

emacs: venv emacs-setup ## (optional) Open Emacs with the custom configuration
	@$(ACTIVATE) && $(EMACS) $(EMACSFLAGS) $(PWD)

test: venv ## Run tests for Python code
	@$(ACTIVATE) && pytest $(TESTS_DIR)

format: venv ## Format Python code using Black
	@$(ACTIVATE) && black $(SRC_DIR) $(TESTS_DIR)

typecheck: venv ## Run type checking on Python code using mypy
	@$(ACTIVATE) && mypy $(SRC_DIR)

freeze: venv ## Freeze dependencies in requirements.txt
	@$(ACTIVATE) && $(PIP) freeze > requirements.txt

thumbnails: ## Create thumbnails for JPEG images in the images directory
	@echo "Creating thumbnails..."
	@mkdir -p $(THUMBS_DIR)
	@for img in $(IMAGES_DIR)/*.{jpg,jpeg}; do \
		if [ -f "$$img" ]; then \
			base=$$(basename "$$img" | sed 's/\.[^.]*$$//'); \
			convert -geometry 480x480 "$$img" "$(THUMBS_DIR)/$$base-thumb.png"; \
			echo "Created thumbnail for $$img"; \
		fi; \
	done
	@echo "Thumbnail creation complete!"

clean: ## Clean up the environment
	@echo "Cleaning up..."
	@rm -rf $(VENV)
	@rm -rf $(THUMBS_DIR)
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "Cleanup complete!"
