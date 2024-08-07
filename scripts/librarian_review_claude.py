#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
librarian_review_claude.py

This script uses collect_text_files.py to gather repository content or uses
default files, combines it with librarian prompts, and sends a query to Claude for review.

Author: [Your Name]
Date: [Current Date]
Version: 1.1.0
"""

import json
import os
from typing import Dict, Optional, List
import click
import anthropic
from collect_text_files import collect_files

# Default files to review if no repository path is provided
DEFAULT_FILES = [
    "Dockerfile",
    "Makefile",
    "README.org",
    "pyproject.toml",
    "src/boston_python_llm_tokenizer/__init__.py",
    "tests/test_tokenizer.py"
]

def read_template(template_path: str) -> str:
    """Read the content of the template file."""
    with open(template_path, 'r', encoding='utf-8') as f:
        return f.read()

def prepare_prompt(template: str, repository_files: Dict[str, Optional[str]], librarian_review: str) -> str:
    """Prepare the prompt for Claude by filling in the template."""
    file_list = "\n".join(repository_files.keys())
    filled_template = template.replace("{{REPOSITORY_FILES}}", file_list)
    filled_template = filled_template.replace("{{LIBRARIAN_REVIEW}}", librarian_review)
    return filled_template

def get_claude_review(prompt: str, api_key: str) -> str:
    """Send a prompt to Claude and get the review."""
    client = anthropic.Client(api_key)
    response = client.completion(
        prompt=prompt,
        model="claude-2.0",
        max_tokens_to_sample=2000,
    )
    return response.completion

def collect_default_files() -> Dict[str, Optional[str]]:
    """Collect contents of default files."""
    collected_files = {}
    for file_path in DEFAULT_FILES:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                collected_files[file_path] = f.read()
        except Exception as e:
            click.echo(f"Error reading file {file_path}: {e}", err=True)
            collected_files[file_path] = None
    return collected_files

@click.command()
@click.argument('repository_path', type=click.Path(exists=True, file_okay=False, dir_okay=True), required=False)
@click.option('--template', type=click.Path(exists=True, file_okay=True, dir_okay=False), default='librarian_prompts.tmpl')
@click.option('--include-git', is_flag=True, help="Include files ignored by git.")
@click.option('--include-dotfiles', is_flag=True, help="Include dotfiles.")
@click.option('--list-binary', is_flag=True, help="List binary files (without content).")
@click.option('--output', '-o', type=click.File('w'), default='-')
def main(repository_path: Optional[str], template: str, include_git: bool, include_dotfiles: bool, list_binary: bool, output: click.File):
    """Collect repository files or use defaults, prepare a prompt, and get a review from Claude."""
    if repository_path:
        # Collect repository files
        repository_files = collect_files(repository_path, include_git, include_dotfiles, list_binary)
    else:
        # Use default files
        repository_files = collect_default_files()
        click.echo("No repository path provided. Using default files.", err=True)

    # Read the template
    template_content = read_template(template)

    # Hardcoded librarian review
    librarian_review = "Dockerfile Makefile README.org pyproject.toml src/boston_python_llm_tokenizer/* tests/*"

    # Prepare the prompt
    prompt = prepare_prompt(template_content, repository_files, librarian_review)

    # Get the review from Claude
    api_key = os.getenv('ANTHROPIC_API_KEY')
    if not api_key:
        raise click.ClickException("ANTHROPIC_API_KEY environment variable is not set.")
    
    review = get_claude_review(prompt, api_key)

    # Write the review to the output
    click.echo(review, file=output)

if __name__ == '__main__':
    main()
