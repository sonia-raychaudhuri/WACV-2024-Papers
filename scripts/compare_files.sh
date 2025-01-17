#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

SOURCE_DIR="$1"
TARGET_DIR="$2"

# Create an array to store files that need to be updated
files_to_update=()

if [ -d "$TARGET_DIR" ]; then
  for file in $(find "$SOURCE_DIR" -type f -name '*.json'); do
    target_file="$TARGET_DIR/$(basename "$file")"
    if [ -e "$target_file" ]; then
      # Check if files differ
      if ! cmp -s "$target_file" "$file"; then
        # Print the filename and a message indicating files differ
        if [ ${#files_to_update[@]} -eq 0 ]; then
          # Create a header for the table if it's the first differing file
          echo -e "File\t\t${RED}Comparison Result${NC}"
        fi
        echo -e "$(basename "$file")\t\t${RED}Files differ${NC}"
        # Display unified diff without lines starting with + or -
        colordiff -u "$target_file" "$file" | sed -n '/^[^+-]/p'
        # Update the target file
        cp "$file" "$target_file"
        files_to_update+=("$(basename "$file")")
      fi
    else
      # Print the filename and a message indicating absence in TARGET_DIR
      echo -e "$(basename "$file")\t\tNot present in TARGET_DIR"
      # If target file doesn't exist, copy it and add to the update list
      cp "$file" "$target_file"
      files_to_update+=("$(basename "$file")")
    fi
  done
else
  echo "Target directory '$TARGET_DIR' does not exist. Creating it ..."
  mkdir -p "$TARGET_DIR"
fi

if [ ${#files_to_update[@]} -eq 0 ]; then
  echo "No files to update."
else
  # Output the list of updated files
  echo -e "\nUpdated files:"
  for updated_file in "${files_to_update[@]}"; do
    echo -e "${GREEN}$updated_file${NC}"
  done
fi
