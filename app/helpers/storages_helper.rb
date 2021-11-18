# frozen_string_literal: true

module StoragesHelper
  def display_payout_optioins(type)
    Space::RENT_PAYOUT_TYPE.keys.map do |k|
      label = I18n.t("users.storages.edit.rent_payout_type.#{k}")
      label.concat('(current payout schedule)') if k.to_s == type
      [label, k]
    end
  end
end
