# frozen_string_literal: true

module SimplyTheTenant
  module ModelExt
    extend ActiveSupport::Concern

    class_methods do
      def simply_the_tenant
        SimplyTheTenant.tenant_class = self if SimplyTheTenant.tenant_class.blank?
      end

      def belongs_to_tenant(tenant_name, query_constraints: [ SimplyTheTenant.tenant_id, :id ], through: nil)
        SimplyTheTenant.tenant_class = tenant_name.to_s.classify.constantize if SimplyTheTenant.tenant_class.blank?

        if through.present?
          delegate(tenant_name, to: through)
        else
          setup_default_methods(tenant_name)
          set_query_contraints(query_constraints)
        end
      end

      private

      def set_query_contraints(constraints)
        return if constraints.blank?

        query_constraints(*constraints)
      end

      def setup_default_methods(tenant_name)
        belongs_to(tenant_name)

        validates(tenant_name, presence: true)

        before_validation(:set_tenant, on: :create)

        default_scope do
          if SimplyTheTenant.global_access?
            all
          else
            tenant_id = SimplyTheTenant.tenant_id
            tenant = SimplyTheTenant.tenant

            raise SimplyTheTenant::NoTenantSetError if tenant.blank?

            where(self.arel_table[tenant_id].eq(tenant.id))
          end
        end
      end
    end

    included do
      private

      define_method("set_tenant") do
        tenant_name = SimplyTheTenant.tenant_name
        tenant_id = SimplyTheTenant.tenant_id

        return if send(tenant_id).present?

        send("#{tenant_name}=", SimplyTheTenant.tenant)
      end
    end
  end
end
