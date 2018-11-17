require 'value_object'

class User < ApplicationRecord
  include ValueObject::Accessor

  value_object_accessor :email
end
