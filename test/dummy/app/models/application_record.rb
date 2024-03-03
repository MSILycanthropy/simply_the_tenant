# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include SimplyTheTenant::ModelExt

  primary_abstract_class
end
