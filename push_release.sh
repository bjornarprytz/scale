#!/bin/bash

# Function to check if the input is a valid version string
is_valid_version() {
    [[ $1 =~ ^v[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]
}

# Get the most recent tag
latest_tag=$(git describe --tags --abbrev=0)

# Extract major, minor, and patch versions
major=$(echo $latest_tag | cut -d. -f1)
minor=$(echo $latest_tag | cut -d. -f2)
patch=$(echo $latest_tag | cut -d. -f3)

# Increment the minor version
new_minor=$((minor + 1))

# Create the new version string
if [ -n "$patch" ]; then
    new_version="$major.$new_minor.$patch"
else
    new_version="$major.$new_minor"
fi

# Prompt for user input and validate the new version string
while true; do
    echo -n "New version (default: $new_version): "
    read user_input

    if [ -z "$user_input" ]; then
        user_input=$new_version
    fi

    if is_valid_version "$user_input"; then
        new_version=$user_input
        break
    else
        echo "Invalid version format. Please use the format v1.2 or v1.3.4."
    fi
done

release_description="New version: $new_version"

# Check if an argument is provided
if [ -n "$1" ]; then
    release_description=$1
else
    # If no argument is provided, prompt the user
    echo -n "Enter a release description (default: $release_description): "
    read user_input
    if [ -n "$user_input" ]; then
        release_description="$user_input"
    fi
fi

# Create a new tag and push it to GitHub
git tag -a $new_version -m "$release_description"
git push origin $new_version

echo "Created release ($new_version): $release_description"

repo_url=$(git remote get-url origin)  # Get the repository URL
repo_url=${repo_url%.git}  # Remove the .git extension
actions_url="$repo_url/actions"  # Append /actions to the URL

# Print the link to the Actions page
echo "Follow publish action here:"
echo $actions_url
