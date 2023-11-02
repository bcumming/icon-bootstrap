#!/bin/bash

# Check if two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Error: You must provide a source and a destination path."
    exit 1
fi

# Assign arguments to variables
SOURCE=$1/_source-cache
DESTINATION=$2/_source-cache

# Check if the source path exists
if [ ! -d "$SOURCE" ]; then
    echo "Error: The source path does not exist."
    exit 1
fi

# Check if the destination path exists
if [ ! -d "$DESTINATION" ]; then
    echo "Error: The destination path does not exist and/or contain _source-cache."
    exit 1
fi

echo "=== synching mirrors from $SOURCE to $DESTINATION"

# Perform the rsync
echo rsync -av --progress "$SOURCE/" "$DESTINATION"
rsync -av --progress "$SOURCE/" "$DESTINATION"

