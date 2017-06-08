require 'date'
require 'dry-validation'

VALUE_TYPES = [ Array, BigDecimal, Date, DateTime, Float, Hash, Integer, String, Time ].freeze

# Base
class BaseModel
  class << self
    attr_accessor :fields

    def schema
      return @schema if defined? @schema
      list = fields
      @schema = Dry::Validation.Schema do
        list.each do |key, value|
          if VALUE_TYPES.include? value
            required( key ).value( type?: value )
          elsif defined? value.schema
            required( key ).schema( value.schema )
          elsif value.is_a? Hash
            required( key ).schema do
              value.each do |sub_key, sub_value|
                if VALUE_TYPES.include? sub_value
                  required( sub_key ).value( type?: sub_value )
                else
                  required( sub_key ).filled
                end
              end
            end
          else
            required( key ).filled
          end
        end
      end
    end
  end
end

# Child 1
class Model1 < BaseModel
  @fields = {
    m1_1: String,
    m1_2: Integer,
    m1_3: true,
    mod1_obj: {
      m1_s1_1: Date
    }
  }
end

# Child 2
class Model2 < BaseModel
  @fields = {
    m2_1: Integer,
    mod1: Model1
  }
end

###

data = { m2_2: 2, mod1: { m1_1: '3', m1_3: '5' } }
data[:m2_1] = 1
data[:mod1][:m1_2] = 4
data[:mod1][:mod1_obj] = { m1_s1_1: Date.today }

result = Model2.schema.call( data )
p result.success?
p result.errors
