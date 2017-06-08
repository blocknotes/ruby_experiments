require 'dry-validation'

VALUE_TYPES = [ Array, BigDecimal, Date, DateTime, Float, Hash, Integer, String, Time ].freeze

# Base
class BaseModel
  @@schema = Dry::Validation.Schema

  def self.schema
    @@schema
  end
end

# Child
class Model2 < BaseModel
  @@schema = Dry::Validation.Schema do
    required( :kk1 ).value( :int? )
    required( :kk2 ).filled
  end
end

fields = {
  k1: Integer,
  k2: Integer,
  sub: Model2
  # sub: sub_schema
  # sub: {
  #   kk1: String,
  #   kk2: true
  # }
}

schema = Dry::Validation.Schema do
  fields.each do |key, value|
    if value.is_a? Hash
      required( key ).schema do
        value.each do |sub_key, sub_value|
          if VALUE_TYPES.include? sub_value
            required( sub_key ).value( type?: sub_value )
          else
            required( sub_key ).filled
          end
        end
      end
    elsif VALUE_TYPES.include? value
      required( key ).value( type?: value )
    elsif value.ancestors.include? BaseModel
      required( key ).schema( value.schema )
    else
      required( key ).filled
    end
  end
end

data = { k1: 1, k2: 2, sub: { kk1: 3 } }
data[:sub][:kk2] = '4'

result = schema.call( data )

p result.success?
p result.errors
