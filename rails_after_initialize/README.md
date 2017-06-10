# after_initialize

Rails - sometimes it's needed to execute some code before anything else but after Rails core is loaded. A good place to achieve this is using _after_initialize_ in `config/application.rb`:

```ruby
# ... config requires ...
module MyApp
  class Application < Rails::Application
    config.after_initialize do
      # init code here...
    end
  end
end
```
