require 'active_support/inflector'

class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key, :type

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.downcase.underscore + "s"
  end

  def children
    [self]
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

class HasManyThroughOptions
  attr_accessor :name, :type, :through_name, :through_assoc, :source_name, :source_assoc

  def initialize(name, through_assoc, source_name)
    @name = name
    @through_assoc = through_assoc
    @source_name = source_name
    @type = :has_many_through
  end

  def children

    kids = []

    kid = @through_assoc
    kids.push(kid)

    until kid.type != :has_many_through
      kid = kid.through_assoc
      kids.push(kid)
    end

    (kids.length - 2).downto(0) do |x|

      kids[x] = kids[x+1].model_class.assoc_options[kids[x].source_name]

    end

    kids.reverse!

    kid = kids[-1].model_class.assoc_options[source_name]
    kids.push ( kid )

    until kid.type != :has_many_through

      if kids[-1].type == :has_many_through
        kids += (kids.pop.children)
        kid = kids[-1]
      else

        kid = kids[-1].model_class.assoc_options[source_name]
        kids.push (kid)
      end
    end

    kids

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

      result = self.db.execute(<<-SQL).first
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

      results = self.db.execute(<<-SQL)
        SELECT *
        FROM #{options.table_name}
        WHERE #{options.foreign_key.to_s} = #{primary_key_value}
      SQL

      results.map { |info| options.model_class.new(info) }

    end

  end

  def has_many_through(name, through_name, source_name)

    through_options = assoc_options[through_name]
    assoc_options[name] = HasManyThroughOptions.new(name, through_options, source_name)

    define_method(name) do

      assoc_list = through_options.children

      assoc_list += (
        assoc_list[-1].model_class.assoc_options[source_name].children
      )

      assoc_list.reverse!

      query = "SELECT #{assoc_list[0].table_name}.* "

      assoc_list.each_with_index do |assoc, idx|

        if idx == 0
          query += "FROM #{assoc.table_name} "
        else
          query += "JOIN #{assoc.table_name} ON "

          if assoc_list[idx-1].type == :has_many
            query += "#{assoc_list[idx-1].table_name}.#{assoc_list[idx-1].foreign_key} = "
            query += "#{assoc.table_name}.#{assoc_list[idx-1].primary_key} "
          else #assoc_list[idx-1].type == :belongs_to
            query += "#{assoc_list[idx-1].table_name}.#{assoc_list[idx-1].primary_key} = "
            query += "#{assoc.table_name}.#{assoc_list[idx-1].foreign_key} "
          end
        end

      end

      query += "WHERE "

      if assoc_list[-1].type == :has_many
        id_to_find = send( "#{assoc_list[-1].primary_key}" )
        key_name = assoc_list[-1].foreign_key
      else
        id_to_find = send( "#{assoc_list[-1].foreign_key}" )
        key_name = assoc_list[-1].primary_key
      end

      query += "#{assoc_list[-1].table_name}.#{key_name} = #{id_to_find}"

      results = self.db.execute(query)

      results.map { |row| assoc_list[0].model_class.new(row) }

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
