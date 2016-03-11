require './lib/sql_object'

require 'sqlite3'
require 'byebug'

SQLObjectBase.db = SQLite3::Database.new('db_file.db')

class Course < SQLObjectBase
  has_many :enrollments
  has_many_through :students, :enrollments, :student
end

class Enrollment < SQLObjectBase
  belongs_to :student
  belongs_to :course
end

class Student < SQLObjectBase
  has_many :enrollments
  has_many_through :courses, :enrollments, :course
end

class Artist < SQLObjectBase
  has_many :albums
  has_many_through :songs, :albums, :songs
end

class Album < SQLObjectBase
  belongs_to :artist
  has_many :songs
end

class Song < SQLObjectBase
  belongs_to :album
  has_one_through :artist, :album, :artist
end

debugger

puts Artist.all[0].songs.map { |s| s.name }
