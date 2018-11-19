# ValueObject

Value object management for Rails Active Records.

Override getters and setters using custom value object to dry active records from flooding logic.

Tested with Rails 5.

## Installation

Add this line to your application's Gemfile :

```ruby
gem 'value_object', git: 'git@github.com:Snapp-FidMe/rails-value-object.git'
```

And then execute :
```bash
$ bundle
```

## Usage

Considering model User migrated with :

```ruby
class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.datetime :birthdate
      t.string :paypal_id
      t.string :email
    end
  end
end
```

### Basic usage

We can create an email value object :

```ruby
class Email < ValueObject::Base

end
```

And use it in our model :

```ruby
class User < ApplicationRecord
  extend ValueObject::Accessor

  value_object_accessor :email
end

user = User.new(email: 'my@email.com')
user.email #=> value object
```

We can give directly a value object as attribute :

```ruby
user = User.new(email: Email.new('my@email.com'))
user.email #=> value object
```

Accessor use a value object name equal to targeted attribute. We can user another value object type :

```ruby
class User < ApplicationRecord
  extend ValueObject::Accessor

  value_object_accessor :email
  value_object_accessor :paypal_id, Email
end

user = User.new(paypal_id: 'my@email.com')
user.paypal_id #=> Email value object
```

### Methods

```ruby
Email.new(nil).nil? #=> true
Email.new(nil).present? #=> false

Email.new('').blank? #=> true
Email.new('').present? #=> false

Email.new('my@email.com').present? #=> true

Email.new('my@email.com') == Email.new('my@email.com') #=> true

Email.new('my@email.com') <=> Email.new('my@email.com') #=> 0

Email.new('my@email.com').value #=> 'my@email.com'

Email.new('my@email.com').to_s #=> 'my@email.com'

Email.new('my@email.com').to_json #=> "\"user@email.com\""

Email.new('my@email.com').as_json #=> 'user@email.com'
```

### Basic validation

Use custom rails validation when needed.

```ruby
class Email < ValueObject::Base
  FORMAT = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validator

  def valid?
    value.present? && value.match(FORMAT).present?
  end
end

class User < ApplicationRecord
  extend ValueObject::Accessor

  value_object_accessor :email

  validates :email, presence: true, email: { allow_nil: true }
end

user = User.new(email: 'my@email.com')
user.valid? #=> true

user = User.new(email: 'wrong')
user.valid? #=> false, error message at email: :invalid
```

### Custom Validation

Can user validator DSL to give specific validation :

```ruby
class Birthdate < ValueObject::Base

  validator name: 'MajorityValidator', with: ->(record, attribute, value) do
    record.errors.add(:birthdate, :too_young) if value.present? && value.younger_than(18)?
  end

  def younger_than(age)?
    value > Time.zone.now - age.years
  end
end

class User < ApplicationRecord
  extend ValueObject::Accessor

  value_object_accessor :birthdate

  validates :birthdate, majority: true
end

user = User.new(birthdate: Time.zone.now - 19.years)
user.valid? #=> true

user = User.new(birthdate: Time.zone.now - 17.years)
user.valid? #=> false, error message at birthdate: :too_young
```

## TODO

* method_missing redirect method to inner value
* custom validator options to make simpler
* explicit exception when validator override already existing validator

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
