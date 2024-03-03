# frozen_string_literal: true

module SimplyTheTenant
  module ModelExt
    extend ActiveSupport::Concern

    class_methods do
      def simply_the_tenant
        SimplyTheTenant.tenant_class = self if SimplyTheTenant.tenant_class.blank?
      end

      def has_many(name, *args, **kwargs)
        name_class = name.to_s.classify.constantize

        if name_class.column_names.exclude?(SimplyTheTenant.tenant_id.to_s)
          super(name, *args, query_constraints: [ "#{self.name.downcase}_id" ], **kwargs)

          return
        end

        super(name, *args, **kwargs)
      end

      def has_one(name, *args, **kwargs)
        name_class = name.to_s.classify.constantize

        if name_class.column_names.exclude?(SimplyTheTenant.tenant_id.to_s)
          super(name, *args, query_constraints: [ "#{self.name.downcase}_id" ], **kwargs)

          return
        end

        super(name, *args, **kwargs)
      end

      def belongs_to(name, *args, **kwargs)
        belongs_to_tenant(name) if name == SimplyTheTenant.tenant_name

        if column_names.exclude?(SimplyTheTenant.tenant_id.to_s)
          # TODO: support key specification here
          super(name, *args, query_constraints: [ "#{name}_id" ], **kwargs)

          return
        end

        super(name, *args, **kwargs)
      end

      private

      def belongs_to_tenant(tenant_name)
        SimplyTheTenant.tenant_class = tenant_name.to_s.classify.constantize if SimplyTheTenant.tenant_class.blank?

        validates(tenant_name, presence: true)

        before_validation(:set_tenant, on: :create)

        query_constraints(SimplyTheTenant.tenant_id, :id)

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

        return if send(tenant_id).present?

        send("#{tenant_name}=", SimplyTheTenant.tenant)
      end
    end
  end
end
