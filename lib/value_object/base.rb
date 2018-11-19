module ValueObject
  class Base
    attr_reader :value

    class << self
      def validator(options = {})
        validator_name = options[:name] || "#{name.underscore.gsub('/', '_')}_validator".camelize
        custom_validator = Class.new(ActiveModel::EachValidator)
        default_validation_proc = ->(record, attribute, value){ record.errors.add(attribute, :invalid) if value.present? && !value.valid? }
        custom_validator.send(:define_method, :validate_each, &(options[:with] || default_validation_proc))
        Object.const_set(validator_name, custom_validator)
      end
    end

    def initialize(value)
      @value = value
    end

    def valid?
      true
    end

    def nil?
      @value.nil?
    end

    def blank?
      @value.blank?
    end

    def ==(other)
      @value == other.value
    end

    def <=>(other)
      @value <=> other.value
    end

    def to_s
      @value
    end

    def to_json
      value.to_json
    end
  end
end
