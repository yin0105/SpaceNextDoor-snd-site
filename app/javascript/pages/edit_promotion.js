export default class EditPromotionPage {
  constructor() {
    this.$optionsForSelect = $('.select-options')
    this.$discountCode = $('#discount-code')
    this.$noPromotionRadioBtn = $('#no-promotion')
    this.$havePromotionRadioBtn = $('#have-promotion')
    this.$promotionOne = $('#discount-option-one')
    this.$promotionTwo = $('#discount-option-two')
    this.$promotionSix = $('#discount-option-six')
    this.$oneMonthTip = $('#one-month-tip')
    this.$twoMonthsTip = $('#two-months-tip')
    this.$sixMonthsTip = $('#six-months-tip')

    this.displayTips()
    this.toggleOption()
  }

  displayTips() {
    // logic for post discount_code to backend
    // remain promotion tips sync with option
    let discountCode = 0
    if (this.$promotionOne.prop('checked')) {
      discountCode |= 1
      this.$oneMonthTip.removeClass('hidden')
    } else {
      this.$oneMonthTip.addClass('hidden')
    }

    if (this.$promotionTwo.prop('checked')) {
      discountCode |= 2
      this.$twoMonthsTip.removeClass('hidden')
    } else {
      this.$twoMonthsTip.addClass('hidden')
    }

    if (this.$promotionSix.prop('checked')) {
      discountCode |= 4
      this.$sixMonthsTip.removeClass('hidden')
    } else {
      this.$sixMonthsTip.addClass('hidden')
    }

    this.$discountCode.prop('value', discountCode)
  }

  toggleOption() {
    this.$optionsForSelect.parents('form').on('submit', () => {
      if (this.$noPromotionRadioBtn.prop('checked') &&
        this.$discountCode.prop('value') !== '') {
        this.$discountCode.prop('value', '')
      }

      if (this.$havePromotionRadioBtn.prop('checked') &&
        (!this.$promotionOne.prop('checked') && !this.$promotionTwo.prop('checked') && !this.$promotionSix.prop('checked'))) {
        const notify = window.alert
        notify('Please select at least one promotion')
        return false
      }
      return true
    })

    this.$optionsForSelect.change(() => {
      // toggle promotion checkbox disabled or not
      if (this.$noPromotionRadioBtn.prop('checked')) {
        this.$promotionOne.attr('disabled', true)
        this.$promotionTwo.attr('disabled', true)
        this.$promotionSix.attr('disabled', true)
        this.$promotionOne.prop('checked', false)
        this.$promotionTwo.prop('checked', false)
        this.$promotionSix.prop('checked', false)
        this.$oneMonthTip.addClass('hidden')
        this.$twoMonthsTip.addClass('hidden')
        this.$sixMonthsTip.addClass('hidden')
        this.$discountCode.prop('value', '')
      }

      if (this.$havePromotionRadioBtn.prop('checked')) {
        this.$promotionOne.attr('disabled', false)
        this.$promotionTwo.attr('disabled', false)
        this.$promotionSix.attr('disabled', false)
      }

      this.displayTips()
    })
  }
}
