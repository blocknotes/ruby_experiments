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
                elsif defined? sub_value.schema
                  required( sub_key ).schema( sub_value.schema )
                else
                  required( sub_key ).filled
                end
              end
            end
          elsif value.is_a? Array
            unless value.empty?
              row = value.first
              required( key ).each do
                schema do
                  row.each do |sub_key, sub_value|
                    if VALUE_TYPES.include? sub_value
                      required( sub_key ).value( type?: sub_value )
                    elsif defined? sub_value.schema
                      required( sub_key ).schema( sub_value.schema )
                    else
                      required( sub_key ).filled
                    end
                  end
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
    mod1: Model1,
    arr: [{
      m2a_1: Integer,
      m2a_2: String
    }]
  }
end

###

data = { m2_2: 2, mod1: { m1_1: '3', m1_3: '5' } }
data[:m2_1] = 1
data[:mod1][:m1_2] = 4
data[:mod1][:mod1_obj] = { m1_s1_1: Date.today }

data[:arr] = [ { m2a_1: 4, m2a_2: '4' }, { m2a_2: 'boh', m2a_1: 123 } ]

result = Model2.schema.call( data )
p result.success?
p result.errors
