module Dradis
  module Plugins
    module PersistantPermissions
      extend ActiveSupport::Concern

      def update
        @user = User.find(params[:id])

        Permission.transaction do
          Permission.where(component: self.class.engine_name, user_id: params[:id]).destroy_all

          params[:permissions]&.each do |permission|
            # Validate the permission being created is a valid value
            next unless "::Dradis::Pro::Plugins::#{self.class.engine_name.to_s.classify}::PERMISSIONS".constantize.include?(permission)

            Permission.create!(
              component: self.class.engine_name,
              name: permission,
              user_id: params[:id]
            )
          end
        end

        redirect_to main_app.edit_admin_user_permissions_path(params[:id]), notice: "#{@user.name}'s permissions have been updated."
      end

      private

      class_methods do
        attr_accessor :engine_name

        def permissible_engine(value)
          self.engine_name = value
        end
      end
    end
  end
end
