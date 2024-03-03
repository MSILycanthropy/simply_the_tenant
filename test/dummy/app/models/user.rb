# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :my_funny_tenant

  has_many :houses
end
