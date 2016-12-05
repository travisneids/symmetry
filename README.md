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
------------

``` bash
git clone git@github.com:travisneids/symmetry.git
cd symmetry
sudo chmod +x # only necessary if you get a permission denied response when trying to run the script
./init.sh
```