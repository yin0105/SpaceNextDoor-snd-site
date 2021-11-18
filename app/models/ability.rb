# frozen_string_literal: true

class Ability
  include CanCan::Ability

  SPACE_AND_TYPES = [Space, Storage].freeze

  def initialize(user)
    user ||= User.new

    user_type = user.class.name.gsub(/::/, '').underscore

    send("define_#{user_type}_abilities", user)
  end

  def define_user_abilities(user)
    alias_action :create, :read, :update, :destroy, to: :crud

    can :read, SPACE_AND_TYPES, status: Space.statuses[:activated]
    can %i[crud query_spaces], SPACE_AND_TYPES, user_id: user.id
    cannot :crud, SPACE_AND_TYPES, user_id: user.id, status: Space.statuses[:soft_deleted]
    can :show, Space, user_id: user.id
    can :hide, Space, user_id: user.id

    can %i[create update read cancel_long_lease edit_insurance update_insurance edit_transform_long_lease update_transform_long_lease], Order, guest_id: user.id
    can :read, Order, host_id: user.id

    can %i[create read], Payment, user_id: user.id
    can [:read], Payment, order: { host_id: user.id }

    can %i[create read], Channel, guest_id: user.id
    can :read, Channel, space: { user_id: user.id }
    can %i[create read], Message, user_id: user.id
    can %i[read update], Rating, user_id: user.id
  end

  def define_admin_root_abilities(_admin)
    can :manage, :all
  end

  def define_admin_general_abilities(_admin)
    can :manage, :all
    cannot %i[update], User
    cannot %i[create update destroy], Admin
  end
end
