#!/bin/bash
#
# This script will install Symmetry by creating symbolic links from the dotfiles directory of this repo to your home directory

homeDir="${HOME}" # home directory of the current user.  This can be changed if you'd like to keep your dotfiles and backup elsewhere
symmetryDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # directory this script is being run in
symmetryDotfiles="${symmetryDir}/dotfiles" # the dotfiles that will be copied to the homeDir
symmetryBackupDir="${HOME}/.symmetry_backup" # current dotfiles that would otherwise be overwritten

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
    printf "Creating ${symmetryBackupDir} to backup all dotfiles from ${homeDir} found in ./dotfiles ...\n"
    mkdir -p ${symmetryBackupDir}

    for file in dotfiles/*; do
        # we need to strip the "dotfiles/" from file so it just returns the filename
        strippedFile=${file##*/}

        # we only care to backup the file if it matches a file in our dotfiles directory AND if it currently is NOT a symbolic link - because that'd be silly.
        if [[ -f ${homeDir}/.${strippedFile} && ! -L ${homeDir}/.${strippedFile} ]]; then
            printf "Moving ${homeDir}/.${strippedFile}\n"
            mv ${homeDir}/.${strippedFile} ${symmetryBackupDir}/
        else
            printf "Symbolic link for ${strippedFile} already exists.  No need to back up.  Skipping...\n"
        fi
    done

    printf "\nBackup completed!\n\n"
}

#######################################
# Creates symbolic links from the dotfiles directory of this repository into your homeDir (defined at the top of script)
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
create_symbolic_links() {
    printf "Creating symbolic links for all files found in ./dotfiles directory...\n"

    for file in dotfiles/*; do
        # we need to strip the "dotfiles/" from file so it just returns the filename
        strippedFile=${file##*/}

        # if the symbolic link doesn't exit already, create the dammer
        if [[ ! -f ${homeDir}/.${strippedFile} ]]; then
            ln -s ${symmetryDir}/${file} ${homeDir}/.${strippedFile}
        else
            printf "Symbolic link already exists for ${symmetryDir}/${file}.  Skipping...\n"
        fi
    done
}

# this flag is probably never necessary since the backup_symmetry only backups non symbolic links found in the dotfiles directory
# not sure why someone would not want to back those up - you trust me that much? muwahahaha
if [[ $* = "--no-backup" ]]; then
    printf "Skipping backup process...\n"

    exit $(create_symbolic_links)
fi

# run the dammer!
if backup_symmetry && create_symbolic_links ; then
    printf "\nCompleted successfully!\n"
else
    printf "\nThere was an error with the script!\n"
    exit 1
fi
