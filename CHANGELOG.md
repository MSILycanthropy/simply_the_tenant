Unreleased
----------

0.2.1
-----
- Reverts 0.2.0 changes to `belongs_to_tenant` to avoid breaking changes

0.2.0
-----
- Remove `belongs_to_tenant` in favor of overriding `belongs_to`, `has_many`, etc. in the model
- Remove autoloading of `ModelExt` to avoid conflicts with rails
- Add support for relationships that do not belong to a tenant
  - These automatically set query_constraints to avoid issues with multi-tenant relationships

0.1.2
-----
- Correct gemspec to have proper dependencies

0.1.0
-----
- Initial release
