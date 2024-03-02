# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to_tenant :my_funny_tenant
end
