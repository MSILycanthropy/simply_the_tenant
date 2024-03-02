# frozen_string_literal: true

require "test_helper"

class ControllerTest < ActionController::TestCase
  tests ApplicationController

  def setup
    @my_funny_tenant = MyFunnyTenant.create(name: "MyFunnyTenant", subdomain: "my_funny_tenant")
  end

  def teardown
    @my_funny_tenant.destroy
  end

  test "sets the current tenant correctly with subdomain" do
    @request.host = "#{@my_funny_tenant.subdomain}.example.com"
    response = get(:index)

    assert_equal @my_funny_tenant.name, response.body
  end

  test "sets the current tenant correctly with www subdomain" do
    @request.host = "www.#{@my_funny_tenant.subdomain}.example.com"
    response = get(:index)

    assert_equal @my_funny_tenant.name, response.body
  end

  test "raises NoSubdomainError when no subdomain is found" do
    @request.host = "example.com"

    assert_raises(SimplyTheTenant::NoSubdomainError) do
      get :index
    end
  end
end
