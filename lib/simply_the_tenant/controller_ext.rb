# frozen_string_literal: true

module SimplyTheTenant
  module ControllerExt
    extend ActiveSupport::Concern

    class_methods do
      def sets_current_tenant(name)
        SimplyTheTenant.tenant_class = name.to_s.classify.constantize

        around_action(:with_current_tenant)
      end
    end

    included do
      def with_current_tenant(&block)
        SimplyTheTenant.tenant = find_tenant_by_subdomain

        SimplyTheTenant.with_tenant(SimplyTheTenant.tenant, &block)
      end

      def with_global_access(&block)
        SimplyTheTenant.with_global_access(&block)
      end

      private

      def find_tenant_by_subdomain
        SimplyTheTenant.tenant_class.find_by!(subdomain: tenant_subdomain)
      end

      def tenant_subdomain
        subdomain = request.subdomains.last

        raise SimplyTheTenant::NoSubdomainError if subdomain.blank?

        subdomain
      end
    end
  end
end
