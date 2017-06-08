require 'date'
require 'dry-validation'

VALUE_TYPES = [ Array, BigDecimal, Date, DateTime, Float, Hash, Integer, String, Time ].freeze

# Base
class BaseModel
  class << self
    attr_accessor :fields

    # Prepare the dry validation schema
    # @note @fields with the list of fields is required, if type is specified @fields[type] is required
    # @param type [Symbol] the schema type
    # @return [Dry::Validation.Schema] the dry validation schema
    def schema( type = :default )
      @schema = {} unless defined? @schema
      return @schema[type] if @schema.include? type
      set = proc do |rules, values|
        values.each do |key, value|
          if VALUE_TYPES.include? value
            rules.required( key ).value( type?: value )
          elsif defined? value.schema
            rules.required( key ).schema( value.schema( type ) )
          elsif value.is_a?( Hash )
            rules.required( key ).schema { set.call self, value }
          elsif value.is_a?( Array ) && !value.empty?
            rules.required( key ).each do
              rules.schema { set.call self, value.first }
            end
          elsif value.is_a?( FalseClass )
            rules.optional( key )
          else
            rules.required( key ).filled
          end
        end
      end
      list = type == :default ? fields : fields[type]
      @schema[type] = Dry::Validation.Schema { set.call self, list }
    end
  end
end

# Child 1
class Model1 < BaseModel
  @fields = {
    create: {
      a_string: String,
      an_int: false,
      an_obj: {
        a_date: Date
      }
    }
  }
end

# Child 2
class Model2 < BaseModel
  @fields = {
    create: {
      another_int: Integer,
      another_string: true,
      a_model: Model1,
      an_array: [{
        array_int: Integer,
        array_string: String
      }]
    },
    update: {
      another_int: Integer,
      another_string: String
    }
  }
end

###

data = { another_string: 2, a_model: { a_string: '3' } }
data[:another_int] = 1
# data[:a_model][:an_int] = 4
data[:a_model][:an_obj] = { a_date: Date.today }
data[:an_array] = [ { array_int: 4, array_string: '4' }, { array_string: 'boh', array_int: 123 } ]

result = Model2.schema( :create ).call( data )
p result.success?
p result.errors
puts "\n"

###

more_data = { another_string: 'str1', another_int: 0 }

result = Model2.schema( :update ).call( more_data )
p result.success?
p result.errors
puts "\n"

###

p Model1.schema( :create ).rules.keys
p Model2.schema( :create ).rules.keys
# p Model1.schema( :update ).rules.keys
