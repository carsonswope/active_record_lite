# ORM inspired by Ruby on Rails ActiveRecord



Requires a DBConnection class with ::execute, ::execute2, ::last_insert_row_id

::execute simply returns an array of the matching database entries,
::execute2 also returns an array of matching database entries, except the first element of the array is a list of the names of the columns.

run:

rm db_file.db
cat sql_seed.sql | sqlite3 db_file.db
