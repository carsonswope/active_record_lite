# RustlingRecord

RustlingRecord is an ORM inspired by ActiveRecord from Ruby on Rails. It creates Ruby objects out of SQL tables, allowing the user to perform database operations without writing a single line of SQL.

## How to use

The only dependency of RustlingRecord is ActiveSupport, for inferring the pluralized version of class names, or the singular version of table names.

The SQLObjectBase class is the base class all classes that apply the RustlingRecord ORM functionality. Before defining your classes, you must tell the SQLObjectBase class what Ruby database object it will be talking to. As long as the database object responds to ::execute, ::execute2 and ::last_insert_row_id, any type of database object will do. For example, to connect your SQLObjectBase class to an SQLite3 database from a file, you could write:

SQLObjectBase.db = SQLite3::Database.new('db_file.db')






Requires a DBConnection class with ::execute, ::execute2, ::last_insert_row_id

::execute simply returns an array of the matching database entries,
::execute2 also returns an array of matching database entries, except the first element of the array is a list of the names of the columns.

run:

rm db_file.db
cat sql_seed.sql | sqlite3 db_file.db
