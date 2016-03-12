require './lib/sql_object'

require 'sqlite3'
require 'byebug'

SQLObjectBase.db = SQLite3::Database.new('demo/db_file.db')

class Instructor < SQLObjectBase
  has_many :courses
  has_many_through :enrollments, :courses, :enrollments
  has_many_through :students, :enrollments, :student
  has_many_through :notebooks, :enrollments, :notebooks
end

class Course < SQLObjectBase
  belongs_to :instructor
  has_many :enrollments
  has_many_through :students, :enrollments, :student
end

class Enrollment < SQLObjectBase
  belongs_to :student
  belongs_to :course
  has_many_through :notebooks, :student, :notebooks
end

class Student < SQLObjectBase
  has_many :enrollments
  has_many_through :courses, :enrollments, :course
  has_many :notebooks
end

class Notebook < SQLObjectBase
  belongs_to :student
  has_many_through :courses, :student, :courses
  has_one_through :instructor, :courses, :instructor
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

x = Instructor.all[0].notebooks

debugger

puts Artist.all[0].songs.map { |s| s.name }
