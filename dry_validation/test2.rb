require 'dry-validation'

schema = Dry::Validation.Schema do
  required(:address).schema do
    required(:city).filled(min_size?: 3)

    required(:street).filled
    required(:phone_numbers).each(:int?)

    required(:country).schema do
      required(:name).filled
      required(:code).filled
    end
  end
end

data = { address: { city: 'Vicenza', street: 'via boh', country: { name: 'Italy', code: 'IT' } } }
data[:address][:phone_numbers] = [ 4321, 9999, 6543, nil ]
# {:address=>{:phone_numbers=>{3=>["must be an integer"]}}}

result = schema.call( data )

p result.success?
p result.errors
