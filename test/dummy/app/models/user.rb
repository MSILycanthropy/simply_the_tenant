class User < ApplicationRecord
  belongs_to_tenant :my_funny_tenant
end
