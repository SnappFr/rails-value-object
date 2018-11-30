# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../../test/dummy/config/environment.rb', __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path('../../test/dummy/db/migrate', __FILE__)]
require 'rails/test_help'
require 'value_object'



# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path('../fixtures', __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + '/files'
  ActiveSupport::TestCase.fixtures :all
end

ActiveRecord::ConnectionAdapters::AbstractAdapter.descendants.each do |adapter|
adapter.send(:define_method, :type_cast) do |value, column = nil|
    if value.is_a?(ValueObject::Base)
      super(value.value, column)
    else
      super(value, column)
    end
  end
end
