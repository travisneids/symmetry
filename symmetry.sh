#!/bin/bash
#
# This script will install Symmetry by creating symbolic links from the dotfiles directory of this repo to your home directory

SYMMETRY_LIBRARY_NAME="Symmetry"
SYMMETRY_LIBRARY_DESCRIPTION="This script will install Symmetry by creating symbolic links from the dotfiles directory of this repo to your home directory"
SYMMETRY_HOME_DIR="${HOME}" # home directory of the current user.  This can be changed if you'd like to keep your dotfiles and backup elsewhere
SYMMETRY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # directory this script is being run in
SYMMETRY_DOTFILES_DIR="${SYMMETRY_DIR}/dotfiles" # the dotfiles that will be copied to the SYMMETRY_HOME_DIR
SYMMETRY_BACKUP_DIR="${SYMMETRY_HOME_DIR}/.symmetry_backup" # current dotfiles that would otherwise be overwritten

symmetry_echo() {
  command printf %s\\n "$*" 2>/dev/null || {
    symmetry_echo() {
      # shellcheck disable=SC1001
      \printf %s\\n "$*" # on zsh, `command printf` sometimes fails
    }
    symmetry_echo "$@"
  }
}

symmetry_err() {
  >&2 symmetry_echo "$@"
}

#######################################
# Backup any current .files that match the files in the dotfiles directory
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
backup_symmetry() {
    symmetry_echo "Creating ${SYMMETRY_BACKUP_DIR} to backup all dotfiles from ${SYMMETRY_HOME_DIR} found in ./dotfiles ..."

    mkdir -p ${SYMMETRY_BACKUP_DIR}

    for FILE in dotfiles/*; do
        # we need to strip the "dotfiles/" from file so it just returns the filename
        local STRIPPED_FILE=${FILE##*/}

        # we only care to backup the file if it matches a file in our dotfiles directory AND if it currently is NOT a symbolic link - because that'd be silly.
        if [[ -f ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE} && ! -L ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE} ]]; then
            symmetry_echo "Moving ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE}"
            mv ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE} ${SYMMETRY_BACKUP_DIR}/
        else
            symmetry_echo "Symbolic link for ${STRIPPED_FILE} already exists.  No need to back up.  Skipping..."
        fi
    done

    symmetry_echo "Backup completed!"
    symmetry_echo
}

#######################################
# Creates symbolic links from the dotfiles directory of this repository into your SYMMETRY_HOME_DIR (defined at the top of script)
# Globals:
#   None
# Arguments:
#   FILES_TO_SKIP
# Returns:
#   None
#######################################
create_symbolic_links() {
    local FILES_TO_SKIP=$1

    symmetry_echo "Creating symbolic links for all files found in the ./dotfiles directory..."

    for FILE in dotfiles/*; do
        local STRIPPED_FILE=${FILE##*/}

        if [[ ${FILES_TO_SKIP[*]} =~ ${STRIPPED_FILE} ]]; then
            symmetry_echo "Skipping ${STRIPPED_FILE}..."
        else
            if [[ -L ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE} ]]; then
                if [[ $(readlink ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE}) = ${SYMMETRY_DOTFILES_DIR}/${STRIPPED_FILE} ]]; then
                    symmetry_echo "${STRIPPED_FILE} is already linked correctly.  Skipping..."
                else
                    symmetry_err "${STRIPPED_FILE} is already a symbolic link but not to Symmetry.  Skipping..."
                fi
            elif [[ ! -f ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE} ]]; then
                symmetry_echo "Linking ${STRIPPED_FILE}..."
                ln -s ${SYMMETRY_DIR}/${FILE} ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE}
            else
                read -p "${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE} exists and was not backed up.  Would you like to overwrite this file with ${SYMMETRY_DOTFILES_DIR}/${STRIPPED_FILE}? [y/N] " OVERWRITE_DOTFILE

                if [[ $(echo "${OVERWRITE_DOTFILE}" | tr '[:upper:]' '[:lower:]') = "y" ]]; then
                    symmetry_echo "Overwriting..."
                    rm ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE}
                    ln -s ${SYMMETRY_DIR}/${FILE} ${SYMMETRY_HOME_DIR}/.${STRIPPED_FILE}
                else
                    symmetry_echo "Skipping..."
                fi
            fi
        fi
    done

    return 0
}

COMMAND="${1-}"
shift

case ${COMMAND} in
    "sync" )
        SYMMETRY_BACKUP=true
        SYMMETRY_SKIP_FILES=""
        while [ $# -gt 0 ]
        do
            case "$1" in
                --silent) NVM_SILENT='--silent' ; shift ;;
                --no-backup) SYMMETRY_BACKUP=false ; shift ;;
                --lts) NVM_LTS='*' ; shift ;;
                --skip-files) SYMMETRY_SKIP_FILES='*' ; shift ;;
                --lts=*) NVM_LTS="${1##--lts=}" ; shift ;;
                --skip-files=*) SYMMETRY_SKIP_FILES="${1##--skip-files=}" ; shift ;;
                --) break ;;
                --*)
                    symmetry_err "Unsupported flag \"$1\". Run ./symmetry.sh -h for supported sync flags."
                    exit 55
                ;;
                *)
                    if [ -n "$1" ]; then
                        break
                    else
                        shift
                    fi
                ;;
            esac
        done

        if [ "${SYMMETRY_BACKUP}" = false ]; then
            symmetry_echo "Skipping backup process..."
            symmetry_echo

            create_symbolic_links ${SYMMETRY_SKIP_FILES}

            exit 0
        fi

        if backup_symmetry && create_symbolic_links ${SYMMETRY_SKIP_FILES} ; then
            symmetry_echo
            symmetry_echo "Completed Succesfully!"

            exit 0
        else
            symmetry_echo "Looks like there was an error running sync!"

            exit 1
        fi

    ;;
    'help' | '--help' | *)
        symmetry_echo
        symmetry_echo "${SYMMETRY_LIBRARY_NAME}"
        symmetry_echo "${SYMMETRY_LIBRARY_DESCRIPTION}"
        symmetry_echo
        symmetry_echo "Usage:"
        symmetry_echo "  ./symmetry.sh -h, --help                  Show this message"
        symmetry_echo "  ./symmetry.sh sync                        Backup and sync all files in dotfiles directory to your ${SYMMETRY_HOME_DIR}"
        symmetry_echo "    --no-backup                              When syncing, ignore backup of non-symbolically linked files in ${SYMMETRY_HOME_DIR}"
        symmetry_echo "    --skip-files=<filename1,filename2>      When syncing, skip provided file(s) from dotfiles directory"
        symmetry_echo
    ;;
esac
