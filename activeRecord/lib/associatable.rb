require_relative 'sql_object.rb'
require 'active_support/inflector'



class AssocOptions
  attr_accessor :foreign_key, :class_name, :primary_key

  def model_class
    class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
                  :foreign_key => "#{name}_id".to_sym,
                  :primary_key => :id,
                  :class_name => name.to_s.camelcase
                }
    options = defaults.merge(options)

    options.each do |key, value|
      self.send("#{key}=", value)
    end

  end
end


class HasManyOptions < AssocOptions

  def initialize(name, self_class_name, options = {})
    defaults = {
                :foreign_key => "#{self_class_name.underscore}_id".to_sym,
                :primary_key => :id,
                :class_name => name.to_s.singularize.camelcase,
               }

    options = defaults.merge(options)
    options.each do |key, value|
      self.send("#{key}=", value)
    end

  end
end

module Associatable

  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
     foreign_key = self.send(options.foreign_key)
     options
     .model_class
     .where(options.primary_key => foreign_key).first
   end
 end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      primary_key = self.send(options.primary_key)
      options
      .model_class
      .where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      through_table = through_options.table_name
      through_pk = through_options.primary_key
      through_fk = through_options.foreign_key

      source_table = source_options.table_name
      source_pk = source_options.primary_key
      source_fk = source_options.foreign_key

      key_val = self.send(through_fk)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end


end


class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
