/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import $ from 'jquery'
import Rails from '@rails/ujs'
import 'bootstrap'
import 'jquery.payment'
import 'blueimp-file-upload'
import 'slick-carousel'

// vendor
import { SmoothScroll } from 'smoothScroll'
import 'mobileNav'
import 'videoBackground'
import 'tabs'
import 'jcf'
import 'jcf_range_input'
import 'responsiveslides'
import 'select2_full'

// Standard Library
import { CardFormatter } from '../modules/stripe'
import DatePicker from '../modules/datepicker'
import AddressInputs from '../modules/address_inputs'
import CountrySelectInputs from '../modules/country_select_inputs'
import Search from '../modules/search'
import MultipleImageUploaderInputs from '../modules/multiple_image_uploader_inputs'
import BasicImageUploaderInputs from '../modules/basic_image_uploader_inputs'
import StarRatingInputs from '../modules/star_rating_inputs'
import VerificationCode from '../modules/verification_code'
import PricingCalculator from '../modules/pricing_calculator'
import PopupMap from '../modules/popup_map'
import Facebook from '../modules/facebook'
import setSizeGuide from '../modules/set_size_guide'
import getGeoLocation from '../modules/getGeoLocation'
import initNavBar from '../modules/nav_bar'
import { initSlickCarousel, initMobileNav, initBackgroundVideo, initTabs, initCustomForms } from '../modules/plugins_custom_init'
import RangeSliderBuilder from '../modules/jcf_range_slider'

// pages
import { SpacesPage, SpacesMap, SpacePage } from '../pages/spaces'
import { StripeTokenFetcher } from '../pages/payment_methods'
import SharedPage from '../pages/shared'
import EditPromotionPage from '../pages/edit_promotion'
import HostSpacePage from '../pages/host_space_search'
import { editInsurance } from '../pages/edit_insurance'
import { editTransformLongLease } from '../pages/edit_transform_long_lease'
import longLease from '../pages/long_lease'
import { discountOptions } from '../pages/discount_options'

// Plugin Settings
$.fn.select2.defaults.set('theme', 'snd')

Rails.start()

$(document).ready(() => {
  const modules = {}
  const pages = {}

  setSizeGuide()
  getGeoLocation()

  initNavBar()
  initSlickCarousel()
  initMobileNav()
  initBackgroundVideo()
  initTabs()
  initCustomForms()

  // Modules
  modules.cardFormatter = new CardFormatter()
  modules.datePicker = new DatePicker()
  modules.addressInputs = new AddressInputs()
  modules.search = new Search()
  modules.verificationCode = new VerificationCode()
  modules.SmoothScroll = new SmoothScroll({
    anchorLinks: '.smooth-scroll',
    extraOffset: 0,
    wheelBehavior: 'none'
  })
  modules.facebook = new Facebook()
  modules.popupMap = new PopupMap()
  modules.StarRatingInputs = new StarRatingInputs()
  modules.rangeSliders = new RangeSliderBuilder()
  modules.pricingCalculator = new PricingCalculator()
  modules.basicImageUploaderInputs = new BasicImageUploaderInputs()
  modules.countrySelectInputs = new CountrySelectInputs()
  modules.multipleImageUploaderInputs = new MultipleImageUploaderInputs()

  // Below need split into per page
  pages.spacesMap = new SpacesMap('#spaces-map')
  pages.spacesPage = new SpacesPage()
  pages.stripeTokenFetcher = new StripeTokenFetcher('form[data-stripe-token=true]')
  pages.space = new SpacePage()
  pages.shared = new SharedPage()
  pages.editPromotion = new EditPromotionPage()
  pages.shared = HostSpacePage()

  editInsurance()
  editTransformLongLease()
  longLease()
  discountOptions()

  $('.select2 select').select2({ width: '100%' })

  $('.booking-insurance-options select').select2({
    width: '100%',
    theme: 'insurance-options'
  })

  if (typeof ga === 'function') {
    ga('set', 'location', location.pathname)
    ga('send', 'pageview')
  }
})
