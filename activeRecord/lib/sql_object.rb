require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    # If the colomns exist dont do this quesry
    @columns ||= (DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
       #{self.table_name}
      SQL
      .first # Because we use execute2, the first item will be an array with columns names
      .map(&:to_sym)) # map them to all be symbols

  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        attributes[col]
      end

      define_method("#{col}=") do |value|
        attributes[col] = value
      end

    end
  end


  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    # tableize snake_cases a CamelCase var
    @table_name ||= self.to_s.tableize
  end


  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
      SQL
      @all_entities = self.parse_all(results)
  end

  def self.parse_all(results)
    results.map{|result| self.new(result)}
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        "#{self.table_name}"
      WHERE
        id = ?
      SQL
      return nil if result.empty?
      self.new(result.first)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      raise "unknown attribute '#{attr_name}'" unless self.class.columns.include?(attr_name)
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
     self.class.columns.map { |attr| self.send(attr) }

  end

  def insert
    col_names = self.class.columns.drop(1).map(&:to_s).join(",")
    question_marks = col_names.split(",").map{'?'}.join(",")
    DBConnection.execute(<<-SQL, *attribute_values.drop(1) )
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
      SQL
      self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = self.class.columns.map{ |attr| "#{attr} = ?" }.join(", ")
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
    id.nil? ? self.insert : self.update
  end

  def self.first
  item = DynamicConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    ORDER BY
      id
    LIMIT
      1
  SQL
  self.new(item.first) unless item.empty?
end

def self.last
  item = DynamicConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    ORDER BY
      id DESC
    LIMIT
      1
  SQL
  self.new(item.first) unless item.empty?
end

  def where(params)
    where_line = params.keys.map{|key|"#{key} = ?"}.join(" AND ")
    results = DBConnection.execute(<<-SQL, *params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
       #{where_line}
    SQL
    self.parse_all(results)
  end



end
