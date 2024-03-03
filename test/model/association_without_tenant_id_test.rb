# frozen_string_literal: true

require "test_helper"

class AssociationWithoutTenantIdTest < ActiveSupport::TestCase
  def setup
    @my_funny_tenant = MyFunnyTenant.create(name: "MyFunnyTenant", subdomain: "my_funny_tenant")

    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      @user = User.create(name: "User")
    end
  end

  def teardown
    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      User.delete_all
    end

    MyFunnyTenant.delete_all
  end

  test "creates nested record that does not have tenant_id" do
    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      house = @user.houses.create!(name: "House")

      assert house.valid?
      assert_equal @user, house.user
      assert_equal house.name, "House"
    end
  end
end
