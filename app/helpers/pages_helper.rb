# frozen_string_literal: true

module PagesHelper
  def render_policies(policy)
    content_tag(:article, class: 'article-box') do
      concat content_tag(:span, nil, id: policy[:anchor]) if policy[:anchor].present?
      concat content_tag(:h2, policy[:section])
      concat content_tag(:p, simple_format(policy[:content])) if policy[:content].present?

      show_policy_subjects(policy[:subjects]) if policy[:subjects].present?
    end
  end

  def show_policy_subjects(subjects)
    subjects.each do |subject|
      concat content_tag(:h3, subject[:title]) if subject[:title].present?
      concat show_policy_lists('ol', subject[:order_lists]) if subject[:order_lists].present?
      concat show_policy_lists('ul', subject[:unorder_lists]) if subject[:unorder_lists].present?
      concat content_tag(:p, simple_format(subject[:content])) if subject[:content].present?
    end
  end

  def show_policy_lists(list_kind, lists)
    concat content_tag(:p, simple_format(lists[:list_title])) if lists[:list_title].present?

    capture do
      content_tag(list_kind) do
        lists[:lists].each do |list|
          concat content_tag(:li, simple_format(list, {}, wrapper_tag: 'span'))
        end
      end
    end
  end
end
