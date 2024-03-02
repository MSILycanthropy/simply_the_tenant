class ApplicationController < ActionController::Base
  sets_current_tenant :my_funny_tenant

  def index
    render plain: Current.my_funny_tenant.name
  end
end
