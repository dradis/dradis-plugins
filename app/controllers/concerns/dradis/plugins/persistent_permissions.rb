module Dradis
  module Plugins
    module PersistentPermissions
      extend ActiveSupport::Concern

      def update
        @user = User.authors.find(params[:id])

        Permission.transaction do
          Permission.where(component: self.class.component_name, user_id: params[:id]).destroy_all

          permissions_params[:permissions]&.each do |permission|
            # Validate the permission being created is a valid value
            next unless self.class.permissions_validation.call(permission) if self.class.permissions_validation

            Permission.create!(
              component: self.class.component_name,
              name: permission,
              user_id: params[:id]
            )
          end
        end

        redirect_to main_app.edit_admin_user_permissions_path(params[:id]), notice: "#{@user.name}'s permissions have been updated."
      end

      private

      def permissions_params
        params.require(self.class.component_name).permit(permissions: [])
      end

      class_methods do
        attr_accessor :component_name, :permissions_validation

        def permissible_engine(component_name, opts = {})
          self.component_name = component_name
          self.permissions_validation = opts[:validation]
        end
      end
    end
  end
end
