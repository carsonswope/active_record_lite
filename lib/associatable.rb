require 'active_support/inflector'

class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key, :type

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

  def assoc_options
    @assoc_options ||= {}
  end

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

  def has_many_through(name, through_name, source_name)

    through_options = assoc_options[through_name]

    define_method(name) do

      source_options = through_options.model_class.assoc_options[source_name]

      if source_options.type == :has_many
        join_on = " #{source_options.table_name }.#{source_options.foreign_key} =
                    #{through_options.table_name}.#{source_options.primary_key}"
      else #source_options.type == :belongs_to
        join_on = " #{source_options.table_name }.#{source_options.primary_key} =
                    #{through_options.table_name}.#{source_options.foreign_key}"
      end

      if through_options.type == :has_many
        id_to_find = send( "#{through_options.primary_key}")
        where_condition =  "#{through_options.table_name}.#{through_options.foreign_key} =
                            #{id_to_find}"
      else #through_options.type == :belongs_to
        id_to_find = send( "#{through_options.foreign_key}")
        where_condition =  "#{through_options.table_name}.#{through_options.primary_key} =
                            #{id_to_find}"
      end

      results = DBConnection.execute(<<-SQL)
        SELECT #{source_options.table_name}.*
        FROM #{through_options.table_name}
        JOIN #{source_options.table_name} ON #{join_on}
        WHERE #{where_condition}
      SQL

    results.map { |row| source_options.model_class.new(row) }

    end
  end

  #special method just to return one object not wrapped in an array.
  #uses more generic has_many_through method

  def has_one_through(name, through_name, source_name)
    has_many_through("#{name}_as_list", through_name, source_name)
    define_method(name) do
      send("#{name}_as_list").first
    end
  end

end
