[![Gem Version](https://badge.fury.io/rb/simply_the_tenant.svg)](https://badge.fury.io/rb/simply_the_tenant)

# SimplyTheTenant
Short description and motivation.

A simpler alternative to [`acts_as_tenant`](https://github.com/ErwinM/acts_as_tenant). For most applications [`acts_as_tenant`](https://github.com/ErwinM/acts_as_tenant) is probably what you should reach for, it's battletested, and more feature rich.

So, that begs the question, what is the point of this gem at all?

1. I just kinda wanted to write a multitenancy gem. For basically any applications, prefer `acts_as_tenant`, since it's battletested.
2. `acts_as_tenant` uses `ActiveSupport::CurrentAttributes` under the hood, but that isn't exposed to the user. While that isn't exactly hard to add with `acts_as_tenant`, `simply_the_tenant` does this out of the box.
3. `simply_the_tenant` adheres to your domain model. `Current.account` vs `current_tenant`, making things marginally easier to reason about.
4. `simply_the_tenant` uses Rails 7 `query_constraints`, so certain queries will use compound indices, which is nice for anyone who wants to use composite primary keys or sharding.
5. `simply_the_tenant` requires _explicit_ scoping to access the data of a tenant or to access global data.

Overall, `acts_as_tenant` does do all of the things this gem does. `simply_the_tenant` just presents them in a different way and provides less configuration options. If that pleases you, feel free to use `simply_the_tenant` instead!

## Installation
Add this line to your application's Gemfile:

```ruby
gem "simply_the_tenant"
```

# Getting started
Setting up `simply_the_tenant` is essentially identical to `acts_as_tenant`. But, a thing to keep in mind is that `simply_the_tenatn` is strict about naming. There is currently no way to tell `simply_the_tenant` what foreign key to use.

## Model Setup
```ruby
class MyTenant < ApplicationRecord
  simply_the_tenant
end
```

Anything that belongs to the `MyTenant` _must_ have a `my_tenant_id` column.
```ruby
class User < ApplicationRecord
  belongs_to_tenant :my_tenant
end
```

This will set up a default scope, query constraints, automatic setting of `my_tenant_id` and validations for the tenant.

You'll also need to setup a `Current` model if you don't already have one.
```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :my_tenant
end
```

## Controller Setup
`simply_the_tenant` uses the last subdomain from a request to determine the tenant to scope a given request to. There is currently no way to change this in `simple_tenant`

```ruby
class ApplicationController < ActionController::Base
  sets_current_tenant :my_tenant

  def some_cool_action
    # Current.my_tenant is accessible here automatically
  end
end
```

## Background Processing
`simply_the_tenant` currently doesn't support automatically setting the tenant for any background processing libraries out of the box. This will change shortly.

## Testing
`simply_the_tenant` also doesn't support automatically setting the tenant for any testing libraries out of the box. This will change shortly.

## Contributing
1. Fork the repo
2. Make changes
3. Run the tests `bundle exec appraisals bin/test`
4. Run the linter `bundle exec rubocop`
5. Submit a PR

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
