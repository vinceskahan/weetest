# this verifies we're writing to the db
echo "select datetime(dateTime,'unixepoch','localtime') from archive order by rowid desc limit 2;" | sqlite3 /var/tmp/rocky9-archive/weewx.sdb

