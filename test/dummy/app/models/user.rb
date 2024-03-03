# frozen_string_literal: true

class User < ApplicationRecord
  def self.column_names
    [ "id", "my_funny_tenant_id", "name", "created_at", "updated_at" ]
  end

  belongs_to :my_funny_tenant

  has_many :houses
end
