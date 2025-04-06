#!/bin/bash

set -e

# Default config file location
CONFIG_FILE="${HOME}/dotfiles/symlinks.yml"

# Check if yq is installed (for YAML parsing)
if ! command -v yq &> /dev/null; then
    echo "Error: This script requires 'yq' for YAML parsing"
    echo "Install it with: brew install yq"
    exit 1
fi

# Get system information
HOSTNAME=$(hostname)

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found: $CONFIG_FILE"
    echo "Creating a sample config file..."
    
    # Create a sample config file
    cat > "$CONFIG_FILE" << 'EOF'
# Symlinks configuration
# Format:
# - source: /path/to/source (relative to $HOME/dotfiles or absolute)
#   target: /path/to/target (relative to $HOME or absolute)
#   type: file|directory (optional, auto-detected if not specified)
#   conditions:         # Optional conditions
#     hostname: name    # Only create symlink if hostname matches

links:
  # Vim configuration
  - source: vim/vimrc
    target: ~/.vimrc
    
  # Zsh configuration
  - source: zsh/zshrc
    target: ~/.zshrc
    
  # Directory example
  - source: config/nvim
    target: ~/.config/nvim
    type: directory
    
  # Conditional example
  - source: config/specific
    target: ~/.config/specific
    conditions:
      hostname: my-laptop.local
EOF
    
    echo "Sample config created at $CONFIG_FILE"
    echo "Please edit it and run this script again"
    exit 0
fi

echo "Using config file: $CONFIG_FILE"
echo "Current hostname: $HOSTNAME"

# Function to evaluate conditions
evaluate_conditions() {
    local conditions="$1"
    
    # If no conditions, always true
    if [ -z "$conditions" ]; then
        return 0
    fi
    
    # Check hostname condition
    local hostname_condition=$(echo "$conditions" | yq e '.hostname' - 2>/dev/null)
    if [ "$hostname_condition" != "null" ] && [ -n "$hostname_condition" ]; then
        if [[ "$HOSTNAME" != *"$hostname_condition"* ]]; then
            echo "  ⚠️  Skipping due to hostname condition: required=$hostname_condition, actual=$HOSTNAME"
            return 1
        fi
    fi
    
    # Add more condition checks here in the future
    
    return 0
}

# Function to process symlinks from a YAML file
process_symlinks_file() {
    local file="$1"
    echo "Processing symlinks from: $file"
    
    # Process each symlink in the YAML file
    yq e '.links[] | [.source, .target, .type, .conditions] | @json' "$file" | while read -r json_data; do
        # Extract values from JSON
        source=$(echo "$json_data" | jq -r '.[0]')
        target=$(echo "$json_data" | jq -r '.[1]')
        type=$(echo "$json_data" | jq -r '.[2]')
        conditions=$(echo "$json_data" | jq -r '.[3]')
        
        echo "Checking symlink: $target -> $source"
        
        # Check conditions
        if ! evaluate_conditions "$conditions"; then
            continue
        fi
        
        # Handle relative paths for source (relative to dotfiles dir)
        if [[ ! "$source" = /* ]]; then
            source="${HOME}/dotfiles/$source"
        fi
        
        # Handle relative paths for target (relative to HOME)
        target="${target/#\~/$HOME}"
        
        # Ensure source exists
        if [ ! -e "$source" ]; then
            echo "  ⚠️  Warning: Source does not exist: $source"
            continue
        fi
        
        # Get directory of target
        target_dir=$(dirname "$target")
        
        # Create target directory if it doesn't exist
        if [ ! -d "$target_dir" ]; then
            echo "  Creating directory: $target_dir"
            mkdir -p "$target_dir"
        fi
        
        # Check if target already exists
        if [ -e "$target" ] || [ -L "$target" ]; then
            # If it's already a symlink to the correct location, skip
            if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
                echo "  ✓ Symlink already exists and points to correct location: $target -> $source"
                continue
            fi
            
            # Backup existing file/directory
            backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
            echo "  Backing up existing target to $backup"
            mv "$target" "$backup"
        fi
        
        # Create the symlink
        echo "  Creating symlink: $target -> $source"
        ln -sf "$source" "$target"
    done
}

# Process imports first
echo "Checking for imports..."
if yq e '.import' "$CONFIG_FILE" &>/dev/null; then
    yq e '.import[]' "$CONFIG_FILE" | while read -r import_file; do
        # Handle relative paths for imported files (relative to dotfiles dir)
        if [[ ! "$import_file" = /* ]]; then
            import_file="${HOME}/dotfiles/$import_file"
        fi
        
        if [ -f "$import_file" ]; then
            process_symlinks_file "$import_file"
        else
            echo "⚠️  Warning: Import file not found: $import_file"
        fi
    done
fi

# Process main config file
echo "Creating symlinks from main config..."
process_symlinks_file "$CONFIG_FILE"

echo "Done! All symlinks have been created/updated."
