# frozen_string_literal: true

require "test_helper"

class DestroyTest < ActiveSupport::TestCase
  def setup
    @my_funny_tenant = MyFunnyTenant.create(name: "MyFunnyTenant", subdomain: "my_funny_tenant")
    @my_funny_tenant_2 = MyFunnyTenant.create(name: "MyFunnyTenant2", subdomain: "my_funny_tenant_2")

    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      @user = User.create
    end

    SimplyTheTenant.with_tenant(@my_funny_tenant_2) do
      @user_2 = User.create
    end
  end

  def teardown
    SimplyTheTenant.with_global_access do
      User.delete_all
    end
    @my_funny_tenant.destroy
    @my_funny_tenant_2.destroy
  end

  test "destroys records in the context of the current tenant" do
    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      user = User.first
      user.destroy

      assert_equal 0, User.count
    end
  end

  test "destroys the records across tenant bounds" do
    SimplyTheTenant.with_global_access do
      User.destroy_all

      assert_equal 0, User.count
    end
  end

  test "nesting tenants works" do
    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      user = User.first
      user.destroy

      assert_equal 0, User.count
      SimplyTheTenant.with_tenant(@my_funny_tenant_2) do
        user_2 = User.first
        user_2.destroy

        assert_equal 0, User.count
      end
    end
  end

  test "global access still allows scoping to a tenant" do
    SimplyTheTenant.with_global_access do
      SimplyTheTenant.with_tenant(@my_funny_tenant) do
        user = User.first
        user.destroy

        assert_equal 1, User.count
      end
    end
  end

  test "raises no tenant error if trying to destroy without a scope" do
    assert_raises(SimplyTheTenant::NoTenantSetError) do
      User.first.destroy
    end
  end
end
