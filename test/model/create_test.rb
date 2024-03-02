require 'test_helper'

class QueryTest < ActiveSupport::TestCase
  def setup
    @my_funny_tenant = MyFunnyTenant.create(name: 'MyFunnyTenant', subdomain: 'my_funny_tenant')
  end

  def teardown
    SimplyTheTenant.with_global_access do
      User.delete_all
    end
    @my_funny_tenant.destroy
  end

  test 'creates records in the context of the current tenant' do
    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      user = User.create

      assert_equal @my_funny_tenant, user.my_funny_tenant
    end
  end

  test 'raises no tenant error if trying to query without a scope' do
    assert_raises(SimplyTheTenant::NoTenantSetError) do
      User.create
    end
  end
end
