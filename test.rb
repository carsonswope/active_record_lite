require './lib/sql_object'
require './lib/db_connection'
require 'active_support/inflector'
require 'byebug'

DBConnection.reset

class Course < SQLObject
  has_many :enrollments
  has_many_through :students, :enrollments, :student
end

class Enrollment < SQLObject
  belongs_to :student
  belongs_to :course
end

class Student < SQLObject
  has_many :enrollments
  has_many_through :courses, :enrollments, :course
end

class Artist < SQLObject
  has_many :albums
  has_many_through :songs, :albums, :songs
end

class Album < SQLObject
  belongs_to :artist
  has_many :songs
end

class Song < SQLObject
  belongs_to :album
  has_one_through :artist, :album, :artist
end
