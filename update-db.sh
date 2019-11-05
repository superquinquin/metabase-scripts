#!/bin/sh

set -e

#
#   Display help
#
help()
{
cat <<EOF
$PROGNAME : [OPTIONS]
Restore ERP database 
  --help                    Print this

EOF
}

# Parse command line
while [ "$#" -gt 0 ] ; do
    case $1 in
        --help)
            help
            exit 0
            ;;
		*)
            echo "Unknown option '$1'"
            exit 1
            ;;
    esac
    shift
done

SOURCE=pc01.superquinquin.fr
SOURCE_PORT=22
SOURCE_USER=trobz
SOURCE_DIR=/home/users/trobz/backup-odoo

DEST_DIR=/tmp/restore-odoo
DEST_FILE=latest-db.gz

SSH_BASE="ssh -p ${SOURCE_PORT} ${SOURCE_USER}@${SOURCE}"
SCP_BASE="scp -P ${SOURCE_PORT} ${SOURCE_USER}@${SOURCE}"

# Finding latest file
FILE=`${SSH_BASE} -- ls -t1 ${SOURCE_DIR} | head -n1`
echo "Latest file is ${FILE}"

# SCP file
mkdir -p ${DEST_DIR}
${SCP_BASE}:${SOURCE_DIR}/$FILE ${DEST_DIR}/${DEST_FILE}

# Stopping metabase
sudo /usr/bin/docker stack rm metabase

# Gunzip
echo "Restoring"
dropdb odoo
createdb -O odoo odoo

# We unset error -> due to login
set +e
pg_restore -d odoo ${DEST_DIR}/${DEST_FILE} > /dev/null
set -e

# Alter ?
~/metabase-scripts/alter-table.sh > /dev/null

# Erase restore file
echo "Erasing file"
rm -rvf ${DEST_DIR}

# Restart metabase
sudo /usr/sbin/service metabase start
