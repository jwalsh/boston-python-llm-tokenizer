# Boston Python LLM Tokenizer Makefile

# ====== Variables ======
PYTHON := python3
PIP := pip3
VENV := .venv
BIN := $(VENV)/bin
ACTIVATE := . $(BIN)/activate
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
VENV_MARKER := $(VENV)/.venv_created
SETUP_MARKER := .setup_complete

# ====== Main Targets ======
.DEFAULT_GOAL := help

.PHONY: help setup venv emacs-setup drill emacs test format typecheck freeze thumbnails clean install-deps update-emacs-packages

help: ## Display this help message
	@echo "Usage: make [target]"
	@echo
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup: $(SETUP_MARKER) ## Set up the entire project environment (start here)

$(SETUP_MARKER): $(VENV_MARKER)
	@echo "Setting up Boston Python LLM Tokenizer environment..."
	@mkdir -p $(DRILLS_DIR) $(SRC_DIR) $(IMAGES_DIR) $(THUMBS_DIR)
	@touch $(SRC_DIR)/boston_python_llm_tokenizer/__init__.py
	@$(ACTIVATE) && pip install -e .
	@touch $@
	@echo "Setup complete!"
	@echo "To activate the virtual environment, run: source $(VENV)/bin/activate"

$(VENV_MARKER):
	@echo "Creating virtual environment..."
	@$(PYTHON) -m venv $(VENV)
	@$(ACTIVATE) && $(PIP) install --upgrade pip
	@$(ACTIVATE) && $(PIP) install -r requirements.txt
	@touch $@
	@echo "Virtual environment created and packages installed."

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

# ====== Development Targets ======
drill: $(SETUP_MARKER) ## Open the tokenization drill in Emacs
	@$(ACTIVATE) && $(EMACS) $(EMACSFLAGS) --eval '(progn (find-file "$(DRILLS_DIR)/tokenization-drill.org") (org-drill))'

emacs: $(SETUP_MARKER) ## Open Emacs with the custom configuration
	@$(ACTIVATE) && $(EMACS) $(EMACSFLAGS) $(PWD)

test: $(SETUP_MARKER) ## Run tests for Python code
	@$(ACTIVATE) && PYTHONPATH=src pytest $(TESTS_DIR)

format: $(SETUP_MARKER) ## Format Python code using Black
	@$(ACTIVATE) && black $(SRC_DIR) $(TESTS_DIR)

typecheck: $(SETUP_MARKER) ## Run type checking on Python code using mypy
	@$(ACTIVATE) && mypy $(SRC_DIR)

freeze: $(SETUP_MARKER) ## Freeze dependencies in requirements.txt
	@$(ACTIVATE) && $(PIP) freeze > requirements.txt

# ====== Utility Targets ======
thumbnails: $(SETUP_MARKER) ## Create thumbnails for JPEG images in the images directory
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
	@rm -rf $(VENV) $(THUMBS_DIR) $(SETUP_MARKER)
	@find . -type f -name "*.pyc" -delete
	@find . -type d -name "__pycache__" -delete
	@echo "Cleanup complete!"

install-deps: $(SETUP_MARKER) ## Install project dependencies
	@echo "Installing project dependencies..."
	@$(ACTIVATE) && $(PIP) install nltk transformers torch torchvision torchaudio
	@echo "Dependencies installed. Please run 'make freeze' to update requirements.txt"

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
