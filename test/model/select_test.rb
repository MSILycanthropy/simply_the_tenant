# frozen_string_literal: true

require "test_helper"

class SelectTest < ActiveSupport::TestCase
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

  test "selects records in the context of the current tenant" do
    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      assert_equal @user, User.first
    end

    SimplyTheTenant.with_tenant(@my_funny_tenant_2) do
      assert_equal @user_2, User.first
    end
  end

  test "nesting tenants works" do
    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      assert_equal @user, User.first

      SimplyTheTenant.with_tenant(@my_funny_tenant_2) do
        assert_equal @user_2, User.first

        SimplyTheTenant.with_tenant(@my_funny_tenant) do
          assert_equal @user, User.first
        end
      end
    end
  end

  test "global access queries across tenant bounds" do
    SimplyTheTenant.with_global_access do
      users = User.all

      assert_equal 2, users.size
      assert_equal [ @user, @user_2 ].to_set, users.to_set
    end
  end

  test "global access still allows scoping to a tenant" do
    SimplyTheTenant.with_global_access do
      users = User.where(my_funny_tenant_id: @my_funny_tenant.id)

      assert_equal 1, users.size
      assert_equal @my_funny_tenant, users.first.my_funny_tenant
    end
  end

  test "raises no tenant error if trying to query without a scope" do
    assert_raises(SimplyTheTenant::NoTenantSetError) do
      User.first
    end
  end
end
