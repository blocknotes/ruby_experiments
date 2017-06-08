# Sprockets debugging

Recently I've got an error while compiling the assets for production: `ExecJS::RuntimeError: SyntaxError: Unexpected token punc «(», expected punc «:»`

Unfortunately there aren't more informations about the file / line which causes the compile error from Rails / Sprockets / Uglifier.

Here are some useful help hints:

```ruby
# Pipeline - List all assets processed by Sprockets
Rails.application.assets.each_file { |f| p f }
```

```ruby
# Compile assets for a specific env
bundle exec rake tmp:clear assets:clean assets:precompile RAILS_ENV=staging
```

```ruby
# Look for the file which causes the error
Rails.application.assets.each_file { |f| if f.end_with?( '.js' ); p f; Uglifier.compile( File.read( f ) ); end }
```

Then you could use directly `uglifyjs FILENAME` if needed.
