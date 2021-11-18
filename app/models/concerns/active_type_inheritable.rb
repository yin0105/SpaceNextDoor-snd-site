# frozen_string_literal: true

module ActiveTypeInheritable
  extend ActiveSupport::Concern

  included do
    define_method :"as_#{base_class.name.downcase}" do
      becomes(self.class.base_class)
    end
  end
end
