# frozen_string_literal: true

class SpaceRecommendService
  RECOMMEND_NUM = 6
  RECOMMEND_RANDOM_NUM = 4

  def initialize(search_params = {})
    @user_latlng = get_user_location(search_params[:user_latitude], search_params[:user_longitude])
    @region = search_params[:region]
    @size = search_params[:size] == defult_size_params ? nil : search_params[:size]
    @price = search_params[:price] == defult_price_params ? nil : search_params[:price]
  end

  def start!
    return by_region unless @region.nil?
    return by_user_location unless @user_latlng.nil?
    return by_size unless @size.nil?
    return by_price unless @price.nil?

    by_random
  end

  private

  def get_user_location(latitude, longitude)
    return nil if latitude.blank? || longitude.blank?

    Regions::LatLng.new(latitude, longitude)
  end

  def space_scope
    Space.activated
  end

  def region_latlng
    @region_latlng ||= Regions::AREA_LATLNG
  end

  def by_region
    return by_random if region_latlng[@region].nil?

    space_scope.order_by_distance(region_latlng[@region].latitude, region_latlng[@region].longitude).first(RECOMMEND_NUM)
  end

  def by_user_location
    return by_size if @user_latlng.nil?

    space_scope.order_by_distance(@user_latlng.latitude, @user_latlng.longitude).first(RECOMMEND_NUM)
  end

  def by_size
    return by_price if @size.nil?

    min, _max = @size.split('..').map(&:to_f)
    recommanded_spaces = space_scope.where('area > ?', min.to_f).order(area: :asc).first(RECOMMEND_NUM)
    recommanded_spaces.count.zero? ? by_price : recommanded_spaces
  end

  def by_price
    return by_random if @price.nil?

    min, _max = @price.split('..').map(&:to_f)
    recommanded_spaces = space_scope.where('daily_price_cents > ?', min.to_f).order(daily_price_cents: :asc).first(RECOMMEND_NUM)
    recommanded_spaces.count.zero? ? by_random : recommanded_spaces
  end

  def by_random
    space_scope.order('RANDOM()').first RECOMMEND_RANDOM_NUM
  end

  def defult_size_params
    format('%<min_size>.2f..%<max_size>.2f', min_size: Search::MIN_SEARCH_SIZE.to_f, max_size: Search::MAX_SEARCH_SIZE.to_f)
  end

  def defult_price_params
    format('%<min_price>.2f..%<max_price>.2f', min_price: Search::MIN_SEARCH_SIZE.to_f, max_price: Search::MAX_SEARCH_SIZE.to_f)
  end
end
