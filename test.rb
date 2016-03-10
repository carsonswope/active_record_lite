require './lib/sql_object'
require './lib/db_connection'
require 'active_support/inflector'
require 'byebug'

class Cat < SQLObject

  belongs_to :human, foreign_key: :owner_id
  has_one_through :home, :human, :house

  finalize!

end

class Human < SQLObject

  has_many :cats, foreign_key: :owner_id
  belongs_to :house

  self.table_name = 'humans'
  finalize!

end

class House < SQLObject

  has_many :humans
  has_many_through :cats, :humans, :cats

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
