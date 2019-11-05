#!/bin/bash
for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" odoo` ; do  psql -c "alter table \"$tbl\" owner to odoo" odoo ; done
for tbl in `psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" odoo` ; do  psql -c "alter sequence \"$tbl\" owner to odoo" odoo ; done
for tbl in `psql -qAt -c "select table_name from information_schema.views where table_schema = 'public';" odoo` ; do  psql -c "alter view \"$tbl\" owner to odoo" odoo ; done

