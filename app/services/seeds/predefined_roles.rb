module Seeds
  class PredefinedRoles
    CRUD_PERMISSIONS = { update_permitted: true, create_permitted: true }.freeze
    READONLY_PERMISSIONS = { update_permitted: false, create_permitted: false }.freeze

    def seed!
      all.each(&:save!)
      set_ownerships!
    end

    def set_ownerships!
      bridge_admin.owned_permission_groups = PermissionGroup.all

      broker.owned_permission_groups = [organization_primary_contact] if broker.owned_permission_groups.empty?
    end

    def bridge_admin
      find_permission_group('Bridge Admin').tap do |group|
        group.admin!
        set_permissions group, crud_targets: all_targets + [:usage_import]
      end
    end

    def bridge_audit
      find_permission_group('Bridge Audit').tap do |group|
        group.admin!
        set_permissions group
      end
    end

    def bridge_finance
      find_permission_group('Bridge Finance').tap do |group|
        group.admin!
        set_permissions group, crud_targets: finance_targets
      end
    end

    def bridge_sales
      find_permission_group('Bridge Sales').tap do |group|
        group.admin!
        set_permissions group
      end
    end

    def broker
      find_permission_group('Broker/TPA').tap do |group|
        group.default_for_broker!
        group.not_admin!
        set_permissions group, crud_targets: all_targets
      end
    end

    def organization_primary_contact
      find_permission_group('Organization Primary Contact').tap do |group|
        group.default_for_organization!
        group.not_admin!
        set_permissions group, crud_targets: all_targets
      end
    end

    private
      def all
        @all ||= [
          bridge_admin,
          bridge_audit,
          bridge_finance,
          bridge_sales,
          broker,
          organization_primary_contact
        ]
      end

      def find_permission_group(name)
        PermissionGroup.find_or_initialize_by(name: name)
      end

      def set_permissions(group, crud_targets: [])
        readonly_targets = all_targets - crud_targets

        assign_permissions group, crud_targets, crud
        assign_permissions group, readonly_targets, readonly
      end

      def assign_permissions(group, targets, permissions)
        Array(targets).each do |target|
          group.permissions.find_or_initialize_by(target: target).tap do |permission|
            permission.assign_attributes permissions
          end
        end
      end

      def all_targets
        Permission::ALL_TARGETS
      end

      def finance_targets
        Permission::FINANCE_TARGETS
      end

      def crud
        CRUD_PERMISSIONS
      end

      def readonly
        READONLY_PERMISSIONS
      end
  end
end
