module SimplyTheTenant
  module ModelExt
    extend ActiveSupport::Concern

    class_methods do
      def simply_the_tenant
        SimplyTheTenant.tenant_class = self unless SimplyTheTenant.tenant_class.present?
      end

      def belongs_to_tenant(tenant_name)
        SimplyTheTenant.tenant_class = tenant_name.to_s.classify.constantize unless SimplyTheTenant.tenant_class.present?

        belongs_to tenant_name

        validates tenant_name, presence: true

        before_validation :set_tenant, on: :create

        query_constraints SimplyTheTenant.tenant_id, :id

        default_scope do
          if SimplyTheTenant.global_access?
            all
          else
            tenant_id = SimplyTheTenant.tenant_id
            tenant = SimplyTheTenant.tenant

            raise SimplyTheTenant::NoTenantSetError if tenant.blank?

            where(tenant_id => tenant.id)
          end
        end
      end
    end

    included do
      private

      define_method("set_tenant") do
        tenant_name = SimplyTheTenant.tenant_name
        tenant_id = SimplyTheTenant.tenant_id

        return unless send(tenant_id).blank?

        send("#{tenant_name}=", SimplyTheTenant.tenant)
      end
    end
  end
end
