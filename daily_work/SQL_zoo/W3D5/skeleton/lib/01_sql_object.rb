require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.
class SQLObject
  def self.columns
  return @columns if @columns
  cols = DBConnection.execute2(<<-SQL).first
    SELECT
      *
    FROM
      #{self.table_name}
    LIMIT
      0
  SQL
  cols.map!(&:to_sym)
  @columns = cols
end

def self.finalize!
  self.columns.each do |name|
    define_method(name) do
      self.attributes[name]
    end

    define_method("#{name}=") do |value|
      self.attributes[name] = value
    end
  end
end

  #set table name
  def self.table_name=(table_name)
    @table_name = table_name
  end
  #get name of table for class, defaults to the class name if name missing
  def self.table_name
    if !@table_name
      self.name.tableize
    else
      @table_name
    end
  end

  # fetch all records from DB, generate necessary SQL query
  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    stuff = []
    results.each do |r|
      stuff << self.new(r)
    end
    stuff
  end

  def self.find(id)
    found = DBConnection.execute(<<-SQL, id)
    SELECT
    #{table_name}.*
     FROM
       #{table_name}
     WHERE
       #{table_name}.id = ?
   SQL
   parse_all(found).first
  end

  def initialize(params = {})
    params.each do |k, v|
      if self.class.columns.include?(k.to_sym)
        self.send("#{k}=", v)
      else
        raise "unknown attribute '#{k}'"
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |attr| self.send(attr) }
  end

  def insert
    columns = self.class.columns.drop(1)
    col_names = columns.map{ |elt| elt.to_s }.join(", ")
    question_marks = (["?"] * columns.count).join(", ")

    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns
      .map { |attr| "#{attr} = ?" }.join(", ")

    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        #{self.class.table_name}.id = ?
    SQL
  end

  def save
    if id
      update
    else
      insert
    end
  end
end
