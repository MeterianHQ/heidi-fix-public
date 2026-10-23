#!/usr/bin/env bash
# The functions that the demo scripts share. A demo script sources this file.
# The variable HEIDI_FIX_PROGRAM gives another Heidi Fix program. The default is heidi-fix on the PATH.

BOLD=$'\e[1m'
CYAN=$'\e[36m'
RESET=$'\e[0m'
DEMO_AUTHOR=(-c user.name="Demo Developer" -c user.email=developer@example.invalid
    -c commit.gpgsign=false -c core.hooksPath=/dev/null)

show_title() {
    echo
    echo "${BOLD}${CYAN}== $1 ==${RESET}"
}

wait_for_enter() {
    echo
    read -r -p "${BOLD}Press Enter to continue...${RESET}"
}

show_and_run() {
    echo "${BOLD}\$ $*${RESET}"
    "$@"
}

heidi-fix() {
    "${HEIDI_FIX_PROGRAM:-heidi-fix}" "$@"
}

# Stops the demo when one of the tools is not on the PATH.
verify_the_tools() {
    local tool
    for tool in git "${HEIDI_FIX_PROGRAM:-heidi-fix}" "$@"; do
        command -v "$tool" >/dev/null || { echo "The tool $tool is not installed. See README.md."; exit 1; }
    done
}

# Restores the real name of a project file: pom.xml.sample becomes pom.xml, and dot-gitignore becomes .gitignore.
restore_the_real_name() {
    local name="${1%.sample}"
    local folder
    folder="$(dirname "$name")"
    local file
    file="$(basename "$name")"
    [[ "$file" == dot-* ]] && file=".${file#dot-}"
    echo "$folder/$file"
}

# Copies the files of the project folder to a new repository folder, with their real names.
copy_the_project() {
    local project_folder="$1"
    local repository_folder="$2"
    local file target
    rm -rf "$repository_folder"
    mkdir -p "$repository_folder"
    while IFS= read -r -d '' file; do
        target="$repository_folder/$(restore_the_real_name "${file#"$project_folder"/}")"
        mkdir -p "$(dirname "$target")"
        cp "$file" "$target"
    done < <(find "$project_folder" -type f -print0)
}

# Commits all the files of the repository, with the demo author.
commit_all() {
    local repository_folder="$1"
    local message="$2"
    git -C "$repository_folder" add --all
    git "${DEMO_AUTHOR[@]}" -C "$repository_folder" commit --quiet --message "$message"
}

# Creates a new repository from the project folder, with one commit on the branch main.
create_the_repository() {
    local project_folder="$1"
    local repository_folder="$2"
    local message="$3"
    copy_the_project "$project_folder" "$repository_folder"
    git -C "$repository_folder" init --quiet --initial-branch=main
    commit_all "$repository_folder" "$message"
}
