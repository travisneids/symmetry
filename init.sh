#!/bin/bash
# This script will install Symmetry by creating symbolic links in your home directory

homeDir="${HOME}" # home directory of the current user.  This can be changed if you'd like to keep your dotfiles and backup elsewhere
symmetryDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # directory this script is being run in
symmetryDotfiles="${symmetryDir}/dotfiles" # the dotfiles that will be copied to the homeDir
symmetryBackupDir="${HOME}/.symmetry_backup" # current dotfiles that would otherwise be overwritten

backup_symmetry() {
    printf "Creating ${symmetryBackupDir} to backup all dotfiles from ${homeDir} found in ./dotfiles ...\n"
    mkdir -p ${symmetryBackupDir}

    for file in dotfiles/*; do
        strippedFile=${file##*/}
        if [[ -f ${homeDir}/.${strippedFile} && ! -L ${homeDir}/.${strippedFile} ]]; then
            printf "Moving ${homeDir}/.${strippedFile}\n"
            mv ${homeDir}/.${strippedFile} ${symmetryBackupDir}/
        else
            printf "Symbolic link for ${strippedFile} already exists.  No need to back up.  Skipping...\n"
        fi
    done

    printf "\nBackup completed!\n\n"
}

create_symbolic_links() {
    printf "Creating symbolic links for all files found in ./dotfiles directory...\n"

    for file in dotfiles/*; do
        strippedFile=${file##*/}
        if [[ ! -f ${homeDir}/.${strippedFile} ]]; then
            ln -s ${symmetryDir}/${file} ${homeDir}/.${strippedFile}
        else
            printf "Symbolic link already exists for ${symmetryDir}/${file}.  Skipping...\n"
        fi
    done
}

if [[ $* = "--no-backup" ]]; then
    printf "Skipping backup process...\n"

    exit $(create_symbolic_links)
fi

if backup_symmetry && create_symbolic_links ; then
    printf "\nCompleted successfully!\n"
else
    printf "\nThere was an error with the script!\n"
    exit 1
fi
