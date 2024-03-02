module SimpleTenant
  module ControllerExt
    extend ActiveSupport::Concern

    class_methods do
      def sets_current_tenant(name)
        SimpleTenant.tenant_class = name.to_s.classify.constantize

        around_action :with_current_tenant
      end
    end

    included do
      def with_current_tenant(&)
        find_tenant_by_subdomain

        SimpleTenant.with_tenant(SimpleTenant.tenant, &)
      end

      def with_global_access(&)
        SimpleTenant.with_global_access(&)
      end

      private

      def find_tenant_by_subdomain
        SimpleTenant.tenant_class.find_by(subdomain: tenant_subdomain)
      end

      def tenant_subdomain
        subdomain = request.subdomains.last

        raise SimpleTenant::NoSubdomainError if subdomain.blank?

        subdomain
      end
    end
  end
end
