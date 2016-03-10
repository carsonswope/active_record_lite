require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
    :type
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.downcase.underscore + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key]  || "#{name.to_s.underscore}_id".to_sym
    @class_name = options[:class_name]    || name.to_s.camelcase.singularize
    @primary_key = options[:primary_key]  || :id
    @type = :belongs_to
  end

end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key]  || "#{self_class_name.to_s.underscore}_id".to_sym
    @class_name = options[:class_name]    || name.to_s.camelcase.singularize
    @primary_key = options[:primary_key]  || :id
    @type = :has_many
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})

    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do

      foreign_key_value = send("#{options.foreign_key}")
      return nil if foreign_key_value.nil?

      result = DBConnection.execute(<<-SQL).first
        SELECT *
        FROM #{options.table_name}
        WHERE #{options.primary_key.to_s} = #{foreign_key_value}
      SQL

      options.model_class.new(result)

    end

  end

  def has_many(name, options = {})

    options = HasManyOptions.new(name, self, options)
    assoc_options[name] = options

    define_method(name) do

      primary_key_value = self.id

      results = DBConnection.execute(<<-SQL)
        SELECT *
        FROM #{options.table_name}
        WHERE #{options.foreign_key.to_s} = #{primary_key_value}
      SQL

      results.map { |info| options.model_class.new(info) }

    end

  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
