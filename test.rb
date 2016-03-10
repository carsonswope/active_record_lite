require './lib/01_sql_object'
require './lib/db_connection'
require './lib/04_associatable2'
require 'active_support/inflector'
require 'byebug'

class Cat < SQLObject
  finalize!
end

puts Cat.all[0].attributes

puts Cat.all.map { |cat|
  cat.name
}

debugger

puts 'aug'
puts 'aug'
puts 'poop'
