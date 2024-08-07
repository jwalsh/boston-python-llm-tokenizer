#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
multi_model_librarian_review.py

This script performs a librarian review of repository files using various AI models,
with Ollama as the default local option.

Author: [Your Name]
Date: [Current Date]
Version: 1.1.0
"""

import os
import json
import requests
from typing import Dict, Optional, List
import click

# You'll need to install these libraries:
# pip install openai anthropic google-generativeai transformers torch ollama

import openai
import anthropic
import google.generativeai as genai
from transformers import AutoTokenizer, AutoModelForCausalLM
import ollama

# Available Ollama models
OLLAMA_MODELS = [
    "llama3.1", "zephyr", "reviewer", "llama3", "wizardcoder:13b-python",
    "staff-engineers-9", "staff-engineers-8", "staff-engineers-7",
    "staff-engineers-6", "staff-engineers-5", "staff-engineers-4",
    "staff-engineers-3", "staff-engineers"
]

def read_template(template_path: str) -> str:
    """Read the content of the template file."""
    with open(template_path, 'r', encoding='utf-8') as f:
        return f.read()

def prepare_prompt(template: str, repository_files: Dict[str, Optional[str]], librarian_review: str) -> str:
    """Prepare the prompt by filling in the template."""
    file_list = "\n".join(repository_files.keys())
    filled_template = template.replace("{{REPOSITORY_FILES}}", file_list)
    filled_template = filled_template.replace("{{LIBRARIAN_REVIEW}}", librarian_review)
    return filled_template

def get_openai_review(prompt: str) -> str:
    """Get review using OpenAI's API."""
    client = openai.OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content

def get_anthropic_review(prompt: str) -> str:
    """Get review using Anthropic's API."""
    client = anthropic.Anthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
    response = client.completions.create(
        model="claude-2.0",
        prompt=prompt,
        max_tokens_to_sample=2000
    )
    return response.completion

def get_gemini_review(prompt: str) -> str:
    """Get review using Google's Gemini API."""
    genai.configure(api_key=os.getenv("GOOGLE_AI_API_KEY"))
    model = genai.GenerativeModel('gemini-pro')
    response = model.generate_content(prompt)
    return response.text

def get_huggingface_review(prompt: str) -> str:
    """Get review using a Hugging Face model."""
    API_URL = "https://api-inference.huggingface.co/models/gpt2-large"
    headers = {"Authorization": f"Bearer {os.getenv('HUGGINGFACE_API_KEY')}"}
    response = requests.post(API_URL, headers=headers, json={"inputs": prompt})
    return response.json()[0]['generated_text']

def get_ollama_review(prompt: str, model: str = "llama3.1") -> str:
    """Get review using a local Ollama model."""
    response = ollama.generate(model=model, prompt=prompt)
    return response['response']

def collect_files(repository_path: str) -> Dict[str, Optional[str]]:
    """Collect files from the repository."""
    # Implement this function to collect files from the repository
    # For now, we'll return a dummy dictionary
    return {
        "README.md": "This is a README file.",
        "src/main.py": "print('Hello, World!')",
        "tests/test_main.py": "def test_main(): assert True"
    }

@click.command()
@click.option('--model', type=click.Choice(['ollama', 'openai', 'anthropic', 'gemini', 'huggingface']), default='ollama',
              help="AI model to use for the review (default: ollama)")
@click.option('--ollama-model', type=click.Choice(OLLAMA_MODELS), default='llama3.1',
              help="Specific Ollama model to use (default: llama3.1)")
@click.option('--repository-path', type=click.Path(exists=True, file_okay=False, dir_okay=True), default='.',
              help="Path to the repository (default: current directory)")
@click.option('--template', type=click.Path(exists=True, file_okay=True, dir_okay=False), default='librarian_prompts.tmpl',
              help="Path to the prompt template file")
@click.option('--output', '-o', type=click.File('w'), default='-',
              help="Output file for the review (default: stdout)")
def main(model: str, ollama_model: str, repository_path: str, template: str, output: click.File):
    """Get a librarian review using the specified AI model."""
    repository_files = collect_files(repository_path)
    template_content = read_template(template)
    librarian_review = "README.md Dockerfile Makefile pyproject.toml src/* tests/*"
    prompt = prepare_prompt(template_content, repository_files, librarian_review)

    click.echo(f"Using model: {model}" + (f" ({ollama_model})" if model == 'ollama' else ""), err=True)

    if model == 'ollama':
        review = get_ollama_review(prompt, ollama_model)
    elif model == 'openai':
        review = get_openai_review(prompt)
    elif model == 'anthropic':
        review = get_anthropic_review(prompt)
    elif model == 'gemini':
        review = get_gemini_review(prompt)
    elif model == 'huggingface':
        review = get_huggingface_review(prompt)
    else:
        raise click.ClickException(f"Unsupported model: {model}")

    click.echo(review, file=output)

if __name__ == '__main__':
    main()
