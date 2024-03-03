# frozen_string_literal: true

class House < ApplicationRecord
  def self.column_names
    [ "id", "user_id", "name", "created_at", "updated_at" ]
  end

  belongs_to :user
end
