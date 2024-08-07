import re
import json
from typing import Dict
import click

def read_envrc(file_path: str) -> Dict[str, str]:
    """
    Read the .envrc file and extract environment variables.
    
    Args:
        file_path (str): Path to the .envrc file
    
    Returns:
        Dict[str, str]: Dictionary of environment variables
    
    Raises:
        FileNotFoundError: If the specified file is not found
        ValueError: If the file content is invalid
    """
    env_vars = {}
    export_pattern = re.compile(r'export\s+(\w+)=(.+)')
    
    try:
        with open(file_path, 'r') as file:
            for line in file:
                line = line.strip()
                if line and not line.startswith('#'):
                    match = export_pattern.match(line)
                    if match:
                        key, value = match.groups()
                        # Remove surrounding quotes if present
                        value = value.strip('\'"')
                        env_vars[key] = value
    except FileNotFoundError:
        raise FileNotFoundError(f"File '{file_path}' not found.")
    except Exception as e:
        raise ValueError(f"Error reading file: {e}")
    
    return env_vars

def convert_to_replit_secrets(env_vars: Dict[str, str]) -> str:
    """
    Convert environment variables to Replit Secrets format.
    
    Args:
        env_vars (Dict[str, str]): Dictionary of environment variables
    
    Returns:
        str: JSON string for Replit Secrets
    """
    # Ensure all values are strings
    secrets = {k: str(v) for k, v in env_vars.items()}
    return json.dumps(secrets, indent=2)

@click.command()
@click.argument('envrc_path', type=click.Path(exists=True), default='.envrc')
@click.option('--output', '-o', type=click.File('w'), default='-',
              help="Output file path. Use '-' for stdout (default).")
def main(envrc_path: str, output: click.File):
    """
    Convert a .envrc file to Replit Secrets JSON format.

    This script reads a .envrc file, extracts the environment variables,
    and converts them to a JSON format suitable for Replit's Raw Secrets Editor.

    If ENVRC_PATH is not provided, it defaults to '.envrc' in the current directory.
    """
    try:
        env_vars = read_envrc(envrc_path)
        replit_secrets = convert_to_replit_secrets(env_vars)
        output.write(replit_secrets)
        if output.name != '<stdout>':
            click.echo(f"Secrets written to {output.name}", err=True)
    except (FileNotFoundError, ValueError) as e:
        click.echo(f"Error: {str(e)}", err=True)
        raise click.Abort()

if __name__ == "__main__":
    main()
