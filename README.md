symmetry
========
This repository is my attempt at creating a way to easily keep all of my environment's
consistent with my custom .bash_profile, .bashrc, etc

The bulk of this repository is in the init.sh script.  Everything else is fairly straight
forward and should be easy to replicate by just stealing the script.

What does it do?
----------------
In a nutshell, the init.sh script will reference the subdirectory `./dotfiles/` of this repo
as a reference to know which files to attempt to back up. and then finally create symbolic links
to each of those files to your '~/' (changeable from within the script).

How do you install it?
----------------------
``` bash
git clone git@github.com:travisneids/symmetry.git
cd symmetry
sudo chmod +x # only necessary if you get a permission denied response when trying to run the script
./symmetry.sh sync
```

Usage
-----
There is not much to Symmetry however I did add a few flags that I felt could be necessary.

``` bash
Symmetry
This script will install Symmetry by creating symbolic links from the dotfiles directory of this repo to your home directory

Usage:
  ./symmetry.sh -h, --help                  Show this message
  ./symmetry.sh sync                        Backup and sync all files in dotfiles directory to your /Users/z001q83
    --no-backup                              When syncing, ignore backup of non-symbolically linked files in /Users/z001q83
    --skip-files=<filename1,filename2>      When syncing, skip provided file(s) from dotfiles directory (should match filename without .)
```

Example use with `--skip-files` flag:
``` bash
./symmetry.sh sync --skip-files=bashrc,bash_profile
```

Which Branch?
-------------
Master includes commented dotfiles which has been stripped of redundant code to make it more
digestible.  You can still access my personal dotfiles on the Neidz branch.

Disclaimer
----------
I am by no means a bash expert.  I do however pride myself on best practices which means I spent more time researching best practices in bash vs actually writing the script itself.  With that being said, PLEASE share any knowledge of things that could be done more efficiently, "got yas" or anything that is just straigh up bad.

Thank you!
