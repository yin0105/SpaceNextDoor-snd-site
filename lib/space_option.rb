# frozen_string_literal: true

module SpaceOption
  def self.spaces
    @spaces ||= YAML.safe_load(File.read(Rails.root.join('config', 'spaces.yml')))
    @spaces['spaces']
  end

  def self.aspect(type)
    spaces[type.to_s] || {}
  end

  def self.features(type, reverse = false)
    return aspect(type)['features'] unless reverse

    reverse_and_cache(type, :features)
  end

  def self.facilities(type, reverse = false)
    return aspect(type)['facilities'] unless reverse

    reverse_and_cache(type, :facilities)
  end

  def self.rules(type, reverse = false)
    return aspect(type)['rules'] unless reverse

    reverse_and_cache(type, :rules)
  end

  def self.minimum_rent_days(type, reverse = false)
    return aspect(type)['minimum_rent_days'] unless reverse

    reverse_and_cache(type, :minimum_rent_days)
  end

  def self.reverse_and_cache(type, name)
    @reverse_options ||= {}
    @reverse_options["#{type}_#{name}"] ||= send(name.to_sym, type).to_a.map(&:reverse).to_h
  end
end
