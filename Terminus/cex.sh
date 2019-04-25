#!/bin/bash

#############
# FUNCTIONS #
#############

help()
{
    echo "Usage: ./cex.sh [[[-i verilife ] [-b cex ]] | [-h]]"
}

########
# ARGS #
########

install=
branch=

while [ "$1" != "" ]; do
    case $1 in
        -i | --install )        shift
                                install=$1
                                ;;
        -b | --branch )         branch=$2
                                ;;
        -h | --help )           help
                                exit
    esac
    shift
done

if [ "$install" = "" ]; then
    echo "Pantheon install not specified. Usage: -i verilife"
    exit 1
fi

echo "Pantheon Install: $install"

if [ "$branch" = "" ]; then
    echo "Branch not specified. Usage -b cex"
    exit 1
fi

#########
# LOGIC #
#########

# Create the temporary environment using the live code/database/files.
terminus multidev:create $install.live $branch

# Change mode to SFTP so we can save the config export files to disk.
terminus connection:set $install.$branch sftp

# Run config export on the temporary environment.
terminus drush $install.$branch -- cex -y

# Commit on the temporary environment.
terminus env:commit $install.$branch --message "Orbot: Re-exported active site config."

# Merge active config into the dev environment.
terminus multidev:merge-to-dev $install.$branch

# Delete the temporary environment.
terminus multidev:delete $install.$branch -y
