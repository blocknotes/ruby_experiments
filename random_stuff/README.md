# Random stuff

Here are some random pieces of code:

- [Rails] Load rails app from irb: `require_relative 'config/environment.rb'` (after that `Rails.application` is available)

- [Rails] Translation key for a model (ex. MyModel): `MyModel.model_name.i18n_key`

- [Rails] Dev routes: `/rails/info/properties` - `/rails/info/routes`

- [Rails] Search for notes comments (`[TODO]`, `[FIXME]`,  etc.): `rake notes`

- [Rails] Dump/restore DB structure: `rake db:structure:dump` - `rake db:structure:load`

- [Rails] Funny method: `ActionDispatch::IntegrationTest.i_suck_and_my_tests_are_order_dependent!`
