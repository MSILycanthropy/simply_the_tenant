require 'test_helper'

class UpdateTest < ActiveSupport::TestCase
  def setup
    @my_funny_tenant = MyFunnyTenant.create(name: 'MyFunnyTenant', subdomain: 'my_funny_tenant')
    @my_funny_tenant_2 = MyFunnyTenant.create(name: 'MyFunnyTenant2', subdomain: 'my_funny_tenant_2')

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

  test 'updates records in the context of the current tenant' do
    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      user = User.first
      user.update(name: 'John Doe')

      assert_equal 'John Doe', user.name
    end
  end

  test 'updates the records across tenant bounds' do
    SimplyTheTenant.with_global_access do
      User.update_all(name: 'Global John Doe')

      User.find_each do |user|
        assert_equal 'Global John Doe', user.name
      end
    end
  end

  test 'nesting tenants works' do
    SimplyTheTenant.with_tenant(@my_funny_tenant) do
      user = User.first
      user.update(name: 'John Doe 1')

      assert_equal 'John Doe 1', user.name
      SimplyTheTenant.with_tenant(@my_funny_tenant_2) do
        user_2 = User.first
        user_2.update(name: 'John Doe 2')

        assert_equal 'John Doe 2', user_2.name

        SimplyTheTenant.with_tenant(@my_funny_tenant) do
          user = User.first
          user.update(name: 'John Doe 3')

          assert_equal 'John Doe 3', user.name
        end
      end
    end
  end


  test 'raises no tenant error if trying to update without a scope' do
    assert_raises(SimplyTheTenant::NoTenantSetError) do
      User.first.update(name: 'John Doe')
    end
  end
end
