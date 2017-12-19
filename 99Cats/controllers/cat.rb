require 'require_all'

require_all './././router'
require_all './././activeRecord'

class Cat  < SQLObject
  attr_reader :errors
  has_many :users

  @errors = []
  def invalid_name?
    if self.name == "" || self.name.nil?
      @errors ||= ["Name can NOT be blank!"]
      return true
    end
    false
  end

end
