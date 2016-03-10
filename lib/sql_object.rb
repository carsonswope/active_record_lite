require_relative 'db_connection'
require_relative 'associatable'
require 'active_support/inflector'
require 'byebug'

class SQLObject

  extend Associatable

  def self.columns

    unless @column_names
      @column_names = DBConnection.execute2(<<-SQL).first.map(&:to_sym)
        SELECT
          *
        FROM
          #{table_name}
      SQL
    end
    @column_names

  end

  def self.finalize!

    define_method(:id) do
      attributes[:id]
    end

    define_method("id=") do |id_num|
      attributes[:id] = id_num
    end

    columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      define_method("#{col}=") do |new_value|
        attributes[col] = new_value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.downcase.tableize
  end

  def self.all
    rows = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    parse_all(rows)
  end

  def self.parse_all(results)
    results.map { |row| new(row) }
  end

  def self.find(id)
    row = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = #{id}
    SQL
    return nil if row.empty?
    new(row.first)
  end

  def initialize(params = {})
    self.class.finalize!
    params.each do |attr_name, value|
      raise "unknown attribute '#{attr_name}'" unless methods.include?(attr_name.to_sym) || attr_name == 'id'
      send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    attributes.values
  end

  def insert

    columns_to_save = attributes.keys.select do |key|
      self.class.columns.include?(key) && !attributes[key].nil?
    end

    column_values = columns_to_save.map do |col_name|
      "'#{attributes[col_name]}'"
    end.join(", ")

    DBConnection.execute(<<-SQL)
      INSERT INTO #{self.class.table_name} (#{columns_to_save.join(", ")})
      VALUES ( #{column_values} )
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update

    col_val_pairs = []
    attributes.each do |col, val|
      next if col == :id || !self.class.columns.include?(col)
      col_val_pairs << "#{col} = '#{val}'"
    end

    DBConnection.execute(<<-SQL)
      UPDATE #{self.class.table_name}
      SET #{col_val_pairs.join(", ")}
      WHERE id = #{self.id}
    SQL
  end

  def save
    if attributes[:id]
      update
    else
      insert
    end
  end
end
