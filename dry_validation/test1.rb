require 'dry-validation'

schema = Dry::Validation.Schema do
  required(:name).filled
  required(:age).maybe(:int?)
  optional(:sex).value( included_in?: %w(M F) )
end

hash = { name: 'Jane', email: 'jane@doe.org' }
hash[:age] = 21
hash[:sex] = 'f' # {:sex=>["must be one of: M, F"]}

result = schema.call( hash )

p result.success?
p result.errors
