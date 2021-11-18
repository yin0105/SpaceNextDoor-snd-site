# frozen_string_literal: true

class Storage
  class AsAcceptSNDRules < ActiveType::Record[Form]
    attribute :accepted_snd_rules, :boolean
    validates :accepted_snd_rules, presence: { message: 'You must accept these rules to continue' }
  end
end
