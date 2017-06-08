require 'date'
require 'dry-validation'

VALUE_TYPES = [ Array, BigDecimal, Date, DateTime, Float, Hash, Integer, String, Time ].freeze

# Base
class BaseModel
  class << self
    attr_accessor :fields

    def schema
      return @schema if defined? @schema
      set = proc do |rules, values|
        values.each do |key, value|
          if VALUE_TYPES.include? value
            rules.required( key ).value( type?: value )
          elsif defined? value.schema
            rules.required( key ).schema( value.schema )
          elsif value.is_a?( Hash )
            rules.required( key ).schema { set.call self, value }
          elsif value.is_a?( Array ) && !value.empty?
            rules.required( key ).each do
              rules.schema { set.call self, value.first }
            end
          else
            rules.required( key ).filled
          end
        end
      end
      list = fields
      @schema = Dry::Validation.Schema { set.call self, list }
    end
  end
end

# Child 1
class Model1 < BaseModel
  @fields = {
    m1_1: String,
    m1_2: Integer,
    mod1_obj: {
      m1_s1_1: Date
    }
  }
end

# Child 2
class Model2 < BaseModel
  @fields = {
    m2_1: Integer,
    m2_2: true,
    mod1: Model1,
    arr: [{
      m2a_1: Integer,
      m2a_2: String
    }]
  }
end

###

data = { m2_2: 2, mod1: { m1_1: '3' } }
data[:m2_1] = 1
data[:mod1][:m1_2] = 4
data[:mod1][:mod1_obj] = { m1_s1_1: Date.today }
data[:arr] = 1 # {:arr=>["must be an array"]}
# data[:arr] = [ { m2a_1: 4, m2a_2: '4' }, { m2a_2: 'boh', m2a_1: 123 } ]

result = Model2.schema.call( data )
p result.success?
p result.errors
