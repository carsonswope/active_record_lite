require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    has_many_through("#{name}_as_list", through_name, source_name)
    define_method(name) do
      send("#{name}_as_list").first
    end
  end

  def has_many_through(name, through_name, source_name)

    through_options = assoc_options[through_name]

    define_method(name) do

      source_options = through_options.model_class.assoc_options[source_name]

      if source_options.type == :has_many
        join_on = " #{source_options.table_name}.#{source_options.foreign_key} =
                    #{through_options.table_name}.#{source_options.primary_key}"
      else #source_options.type == :belongs_to
        join_on = " #{source_options.table_name}.#{source_options.primary_key} =
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
end
