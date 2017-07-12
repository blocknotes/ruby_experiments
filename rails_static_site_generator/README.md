# Rails static site generator

The last week-end I decided to try to staticize a Rails website without external dependecies, a sort of fullpage cache. Here you find a task to do it.

- Generate all configured routes: `rake static:generate_all`

- Generate only a specific route: `rake static:generate_all[page]`

- Generate a single resource: `rake static:generate[page,id,2]`

It could also be expanded to generate the sitemap (with a gem like *xml-sitemap*)

## Update after model saving

```ruby
require 'rake'

class Page < ApplicationRecord
  after_save :staticize

  protected

  def staticize
    Rails.application.load_tasks
    Rake::Task['static:generate'].invoke( 'page', 'id', self.id )
  end
end
```
