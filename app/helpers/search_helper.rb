# frozen_string_literal: true

module SearchHelper
  def sort_options
    Search::SORT_OPTIONS.keys.map do |option|
      [I18n.t(".spaces.search_form.sort_options.#{option}"), option]
    end
  end

  def property_options
    Space::PROPERTY.keys.map do |type|
      [I18n.t(".spaces.search_form.space.property.#{type}"), type]
    end
  end
end
