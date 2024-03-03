# frozen_string_literal: true

require "simply_the_tenant/version"
require "simply_the_tenant/engine"

module SimplyTheTenant
  autoload :ModelExt, "simply_the_tenant/model_ext"
  autoload :ControllerExt, "simply_the_tenant/controller_ext"

  @@tenant_class = nil
  @@global_access = false

  class << self
  end
  def self.tenant_class
    @@tenant_class
  end

  def self.tenant_class=(klass)
    @@tenant_class = klass
  end

  def self.tenant_name
    @@tenant_class.name.underscore.to_sym
  end

  def self.tenant_id
    "#{tenant_name}_id"
  end

  def self.tenant
    raise CurrentNeedsTenantError unless Current.respond_to?(tenant_name)

    Current.public_send(tenant_name)
  end

  def self.tenant=(tenant)
    raise CurrentNeedsTenantError unless Current.respond_to?("#{tenant_name}=")

    Current.public_send("#{tenant_name}=", tenant)
  end

  def self.with_global_access
    @@global_access = true

    yield
  ensure
    @@global_access = false
  end

  def self.global_access?
    @@global_access
  end


  def self.with_tenant(tenant)
    raise NilTenantError if tenant.nil?

    previous_tenant = self.tenant
    self.tenant = tenant

    yield
  ensure
    self.tenant = previous_tenant
  end

  class NilTenantError < StandardError
    def initialize
      super("Cannot set a nil tenant.")
    end
  end

  class MultipleTenantError < StandardError
    def initialize
      super("Multiple tenant classes are not supported.")
    end
  end

  class NoTenantSetError < StandardError
    def initialize
      super("No tenant class has been set. Use `SimplyTheTenant.with_tenant` to set a tenant, " \
        "or `SimplyTheTenant.with_global_access` to bypass tenant scoping.")
    end
  end

  class CurrentNeedsTenantError < StandardError
    def initialize
      super("Current needs to respond to the tenant class name. Use `attribute :{tenant_name}` to define the method.")
    end
  end

  class NoSubdomainError < StandardError
    def initialize
      super("No subdomain found in request. Ensure that the request has a subdomain, " \
        "or override `tenant_subdomain` to provide a custom subdomain.")
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include SimplyTheTenant::ModelExt
end

ActiveSupport.on_load(:action_controller) do
  include SimplyTheTenant::ControllerExt
end
