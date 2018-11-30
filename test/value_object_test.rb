require 'test_helper'

class Email < ValueObject::Base

  FORMAT = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  validator

  def valid?
    value.present? && value.match(FORMAT).present?
  end
end

class Birthdate < ValueObject::Base

  validator name: 'BirthdayValidator', with: ->(record, attribute, value) do
    record.errors.add(attribute, :too_young) unless value.older_than_18?
  end

  def valid?
    value.is_a?(DateTime)
  end

  def older_than_18?
    value < Time.zone.now - 18.years
  end
end

class User < ApplicationRecord
  extend ValueObject::Accessor

  value_object_accessor :email
  value_object_accessor :paypal_id, Email
  value_object_accessor :birthdate

  validates :email, presence: true, email: true, uniqueness: true
  validates :birthdate, birthday: { allow_nil: true }
end

class ValueObject::Test < ActiveSupport::TestCase

  test 'can set and get value object from active record' do
    user = User.new(email: Email.new('user@email.com'))

    assert user.email.is_a?(Email)
  end

  test 'can set and get value object from primitive' do
    user = User.new(email: 'user@email.com')

    assert user.email.is_a?(Email)
  end

  test 'can set and get value object with specific type' do
    user = User.new(paypal_id: 'user@email.com')

    assert user.paypal_id.is_a?(Email)
  end

  test 'value objects can be equal' do
    assert_equal Email.new('user@email.com'), Email.new('user@email.com')
  end

  test 'value object can be blank' do
    assert Email.new('').blank?
    refute Email.new('').present?
  end

  test 'value object can be nil' do
    assert_nil Email.new(nil)
    refute Email.new('').present?
  end

  test 'value objects can be compared' do
    assert_equal 0, Email.new('user@email.com') <=> Email.new('user@email.com')
  end

  test 'value objects can call to_json on value' do
    assert_equal 'user@email.com'.to_json, Email.new('user@email.com').to_json
  end

  test 'value objects can call as_json on value' do
    assert_equal 'user@email.com'.as_json, Email.new('user@email.com').as_json
  end

  test 'can validate value object' do
    assert Email.new('user@email.com').valid?
    refute Email.new('invalid').valid?
  end

  test 'can use rails validation to check valid value object' do
    user = User.new(email: 'user@mail.com')

    assert user.valid?
  end

  test 'can use rails validation to check invalid value object' do
    user = User.new(email: 'invalid')

    assert user.invalid?
    assert user.errors.has_key?(:email)
    assert_equal 1, user.errors.details[:email].size
    assert_equal :invalid, user.errors.details[:email].first[:error]
  end

  test 'can use rails custom validation to check invalid value object' do
    user = User.new(birthdate: Time.zone.now - 17.years)

    assert user.invalid?
    assert user.errors.has_key?(:birthdate)
    assert_equal 1, user.errors.details[:birthdate].size
    assert_equal :too_young, user.errors.details[:birthdate].first[:error]
  end

  test 'can create user from value objects' do
    user = User.create(email: 'user@mail.com')

    assert user.present?
    assert User.where(email: 'user@mail.com').present?
  end
end
