module TheRole
  module User
    extend ActiveSupport::Concern
    include TheRole::BaseMethods

    included do
      belongs_to :role, required: false
      before_validation :set_default_role, on: :create
    end

    def the_role
      result = {}
      roles.map do |r|
        result.deep_merge! r.the_role.to_h
      end

      result
    end

    def owner? obj
      return false unless obj
      return true  if admin?

      section_name = obj.class.to_s.tableize
      return true if moderator?(section_name)

      return id == obj.id if obj.is_a?(self.class)

      return id == obj.user_id if obj.respond_to? :user_id
      return id == obj[:user_id] if obj[:user_id]
      return id == obj[:user][:id] if obj[:user]

      false
    end

    private
    def set_default_role
      unless role
        default_role = Role.find_by(name: TheRole.config.default_user_role)
        self.role = default_role if default_role
      end
    end

  end
end