# frozen_string_literal: true

module RatingsHelper
  def rating_subject_for(rating)
    case rating.ratable_type
    when 'Space'
      rating.ratable.spaceable_type
    when 'User'
      case rating.rater_type
      when 'guest'
        'Host'
      when 'host'
        'Guest'
      end
    end
  end

  def rating_note_placeholder_for(rating)
    case rating_subject_for(rating)
    when 'Host'
      'Tell us more about the host. Eg. Host is friendly and accommodative.'
    when 'Guest'
      'Tell us more about the guest. Eg. Guest keeps space neat and clean.'
    when 'Storage'
      'Tell us more about the storage space. Eg. Space is clean and has 24hrs access.'
    end
  end
end
