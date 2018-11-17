module ValueObject
  module Accessor
    def value_object_accessor(name, klass = nil)
      klass = klass || name.to_s.camelize.constantize
      send(:define_method, name) do
        value = super()
        klass.new(value) unless value.nil?
      end
      send(:define_method, "#{name}=") do |value_object|
        if value_object.is_a?(ValueObject)
          super(value_object.value)
        else
          super(value_object)
        end
      end
    end
  end
end
