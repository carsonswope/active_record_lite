# ActiveRegistry

ActiveRegistry is an ORM inspired by ActiveRecord from Ruby on Rails. It creates Ruby objects out of SQL tables, allowing the user to perform database operations without writing a single line of SQL.

## How to set up

The only dependency of ActiveRegistry is ActiveSupport, for inferring the pluralized version of class names, or the singular version of table names.

The SQLObjectBase class is the base class all classes that apply the ActiveRegistry ORM functionality. Before defining your classes, you must tell the SQLObjectBase class what Ruby database object it will be talking to. As long as the database object responds to ::execute, ::execute2 and ::last_insert_row_id, any type of database object will do. For example, to connect your SQLObjectBase class to an SQLite3 database from a file, you could write:

```ruby
SQLObjectBase.db = SQLite3::Database.new('db_file.db')
```

## Sample usage

To see a sample of ActiveRegistry in action, clone this repo onto your machine. It requires Ruby to be installed, but that's all you need. Next, run these commands:

* `$ bundle install`
* `$ rm demo/db_file.db`
* `$ cat demo/sql_seed.sql | sqlite3 demo/db_file.db`

This will set up an sqlite3 database in the demo directory of the repo, seeded with a small number of tables and associations. You can run `$ ruby demo/test.rb` to see the associations that are made possible by ActiveRegistry in action.

## How to use

ActiveRegistry provides each class with some basic methods for manipulating ORM objects:

* `#save`
* `#update`
* `#insert`
* `::find(id)`
* `::all`
* `::table_name`
* `::table_name=`
* `::columns`

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
class Student < SQLObjectBase
end

class Enrollment < SQLObjectBase
  belongs_to :student
end

class Course < SQLObjectBase
  has_many :enrollments
  has_many_through :students, :enrollments, :student
end

class Instructor < SQLObjectBase
  has_many :courses
  has_many_through :enrollments, :courses, :enrollments
  has_many_through :students, :enrollments, :student
end
```

With the corresponding associations in Course and Enrollment, instances in Instructor are now able to call the method `#students`, and get a list of that Instructor's students, or just a list of their names:

```ruby
Instructor.all[0].students
Instructor.all[0].students.map { |s| s.name }
```
