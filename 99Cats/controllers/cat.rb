require 'require_all'

require_all './././router'
require_all './././activeRecord'

class Cat  < SQLObject
  has_many :users

  def invalid_name?
    return self.name == "" || self.name.nil?
  end

end
