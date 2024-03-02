module SimpleTenant
  module ModelExt
    extend ActiveSupport::Concern

    class_methods do
      def simply_the_tenant
        SimpleTenant.tenant_class = self unless SimpleTenant.tenant_class.present?
      end

      def belongs_to_tenant(tenant_name)
        SimpleTenant.tenant_class = tenant_name.to_s.classify.constantize unless SimpleTenant.tenant_class.present?

        belongs_to tenant_name

        validates tenant_name, presence: true

        before_validation :set_tenant, on: :create

        query_constraints SimpleTenant.tenant_id, :id

        default_scope do
          if SimpleTenant.global_access?
            all
          else
            tenant_id = SimpleTenant.tenant_id
            tenant = SimpleTenant.tenant

            raise SimpleTenant::NoTenantSetError if tenant.blank?

            where(tenant_id => tenant.id)
          end
        end
      end
    end

    included do
      private

      define_method("set_tenant") do
        tenant_name = SimpleTenant.tenant_name
        tenant_id = SimpleTenant.tenant_id

        return unless send(tenant_id).blank?

        send("#{tenant_name}=", SimpleTenant.tenant)
      end
    end
  end
end
