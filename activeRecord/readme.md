# Active Record Lite

Active Record Lite is a lightweight object-relational mapping tool built with Ruby. By creating a subclass of the `SQLObject` class, existing tables in the database are mapped to these new classes.

## Example Usage
Using the sample database as an example, one can retrieve a cat that belong to by a specific owner, by running `Cat.first.owner`. To change a property, for example the name, one can simply type
```ruby
cat = Cat.first
cat.name = 'Whisker'
cat.save
```

## Features
[SQLObject](#sql_object)
* [`::all`](#all)
* [`::first`](#first)
* [`::last`](#last)
* [`::find`](#find)
* [`::new`](#new)
* [`::save`](#save)

[Searchable](#searchable)
* [`::where`](#where)

[Associations](#associations)
* [`::belongs_to`](#belongs_to)
* [`::has_many`](#has_many)
* [`::has_one_through`](#has_one_through)

### SQLObject
#### `all`

Will return an array of all entries in the database for the specified table.

Example: `Cat.all`

#### `first`

Will return the first database entry for the specified table (ordered by id).

Example: `Cat.first`

#### `last`

Will return the last database entry for the specified table (ordered by id).

Example: `Cat.last`

#### `find(id)`

Will return the entry in the database with the id matching the argument.

Example: `Cat.find(4)`

#### `new`

Creates a new SQLObject object (which can be modified and then update or insert into the database with the save method below)

Example: `Cat.new`

#### `save`

Depending on if entry exists in database, will either update or insert into database.

Example:
```ruby
cat = Cat.new
cat.name = "Joy"
cat.save
```

### Searchable
#### `where`

Returns the results of a SQL query based on the hash parameters passed in as arguments.

Example: `Cat.where(name: "Whisker")`

### Associations
#### `belongs_to`

Will return base object with the child associated with the selected object.

Example: `Cat.first.owner`

#### `has_many`

Will return base object with the parent associated with the selected object.

Example: `Cat.first.toys`

#### `has_one_through`

Will return base object with the grandparent associated with the selected object.

Example: `Cat.first.house` (will fetch the house through the owner. Calling owner.house)
