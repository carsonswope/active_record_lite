# RustlingRecord

RustlingRecord is an ORM inspired by ActiveRecord from Ruby on Rails. It creates Ruby objects out of SQL tables, allowing the user to perform database operations without writing a single line of SQL.

## How to set up

The only dependency of RustlingRecord is ActiveSupport, for inferring the pluralized version of class names, or the singular version of table names.

The SQLObjectBase class is the base class all classes that apply the RustlingRecord ORM functionality. Before defining your classes, you must tell the SQLObjectBase class what Ruby database object it will be talking to. As long as the database object responds to ::execute, ::execute2 and ::last_insert_row_id, any type of database object will do. For example, to connect your SQLObjectBase class to an SQLite3 database from a file, you could write:

```ruby
SQLObjectBase.db = SQLite3::Database.new('db_file.db')
```

## Sample usage

To see the RustlingRecord in action, download this directory. You need to have Ruby installed, but that's all you need. Next, run these commands:

`bundle install
rm demo/db_file.db
cat demo/sql_seed.sql | sqlite3 demo/db_file.db
ruby demo/test.rb`

## How to use

Once you have set up the database connections, you can create classes. The methods that you have access to are:

`#save`
`#update`
`#insert`
`::find(id)`
`::all`
`::table_name`
`::table_name=`
`::columns`

You can also set up has_many and belongs_to association methods, a la ActiveRecord:

```ruby
class Album
  belongs_to :artist
  has_many :songs
end
```

This allows you to find the artist or songs list for an instance of an album:

```ruby
Album.all[0].artist
Album.all[0].songs
```

has_many_through associations are supported, and they can be chained as deeply as you want:

```ruby
class Artist
  has_many :albums
  has_many_through :songs, :albums, :songs
end
```

This enables you to call the method #songs on an instance of Artist, returning all of that artist's songs:

```ruby
Artist.all[0].songs
```
