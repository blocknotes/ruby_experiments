require 'dry-validation'

schema = Dry::Validation.Schema do
  [ :k1, :k2, [ :kk1, :kk2 ] ].each do |key|
    if key.is_a? Array
      key.each do |sub_key|
        required( sub_key ).filled
      end
    else
      required( key ).filled
    end
  end
end

data = { k2: '...' }

result = schema.call( data )

p result.success?
p result.errors
