import PricingCalculator from '../modules/pricing_calculator'
import displayInformationNotices from '../modules/display_information_notices'

const oneDayInMilliseconds = 24 * 60 * 60 * 1000

const isAllDaysAvailable = (checkInDate, availableDates, requiredDays) => {
  const checkOutDate = Date.parse(
    availableDates[availableDates.indexOf(checkInDate) + requiredDays - 1])
  const availableDays = ((checkOutDate - Date.parse(checkInDate)) / oneDayInMilliseconds) + 1
  return availableDays >= requiredDays
}

const discountOptions = () => {
  let $selectedOptionID
  const $tips = { 1: $('#discount-code-1-tip'),
    2: $('#discount-code-2-tip'),
    3: $('#discount-code-3-tip')
  }
  const pricingCalculator = new PricingCalculator()

  const discountOneMonthDays = 89
  const discountTwoMonthsDays = 179
  const discountSixMonthsDays = 179
  const discountRequiredDaysOneMonth = 90
  const discountRequiredDaysTwoMonths = 180
  const discountRequiredDaysSixMonths = 180

  const $checkIn = $('.pricing-calculator__from')
  const $checkOut = $('.pricing-calculator__to')
  const $bookButton = $('.space__booking-book > button')
  const $discountOneMonthOption = $('#discount-code-1')
  const $discountTwoMonthsOption = $('#discount-code-2')
  const $discountSixMonthsOption = $('#discount-code-3')
  const $noDiscountOption = $('#order_discount_code_')
  const $discountAreaTitle = $('.discount-area-title')
  const $discountOneMonthError = $('.space__booking-datepicker-discount-one-month-error')
  const $discountTwoMonthsError = $('.space__booking-datepicker-discount-two-months-error')
  const $discountSixMonthsError = $('.space__booking-datepicker-discount-six-months-error')
  const $promotionBlock = $('.space__booking-discount-options')
  const $optionsForDiscount = $('.discount-options-checkboxes')
  const $availableBookingSlot = $('.space__booking-datepicker .flatpickr-input')
  const $discountCode = $('.space__booking-promotion-val')

  const getDate = (startAt, days) => {
    const newCheckOut = startAt + (oneDayInMilliseconds * days)
    const fullDate = new Date(newCheckOut)
    const year = fullDate.getFullYear()
    const month = fullDate.getMonth()
    const day = fullDate.getDate()

    return [year, month, day]
  }

  /* eslint no-underscore-dangle: ["error", { "allow": ["_flatpickr"] }] */
  const setDiscountCheckOutDate = (days) => {
    const checkInDate = $checkIn.val()
    const parsedCheckInDate = Date.parse(checkInDate)

    const newCheckOutDate = getDate(parsedCheckInDate, days)
    $checkOut[0]._flatpickr.setDate(new Date(`${newCheckOutDate[0]}/${newCheckOutDate[1] + 1}/${newCheckOutDate[2]}`))
  }

  const fillPromotionNeededDays = () => {
    if ($selectedOptionID === 'discount-code-1') {
      setDiscountCheckOutDate(discountOneMonthDays)
    } else if ($selectedOptionID === 'discount-code-2') {
      setDiscountCheckOutDate(discountTwoMonthsDays)
    } else if ($selectedOptionID === 'discount-code-3') {
      setDiscountCheckOutDate(discountSixMonthsDays)
    }
  }

  const updatePromotionVal = () => {
    if ($selectedOptionID === 'discount-code-1' || $selectedOptionID === 'discount-code-2' || $selectedOptionID === 'discount-code-3') {
      $discountCode.prop('value', $selectedOptionID)
    } else {
      $discountCode.prop('value', '')
    }
  }

  const displayPromotionOptions = (show) => {
    if (show === true) {
      $promotionBlock.removeClass('hidden')
    } else {
      $promotionBlock.addClass('hidden')
    }
  }

  const promotionIsValid = () => {
    const checkInDate = Date.parse($checkIn.val())
    const checkOutDate = Date.parse($checkOut.val())
    const totalDays = ((checkOutDate - checkInDate) / oneDayInMilliseconds) + 1
    let isValid = true

    if (($selectedOptionID === 'discount-code-1' && totalDays < discountRequiredDaysOneMonth) ||
      ($selectedOptionID === 'discount-code-2' && totalDays < discountRequiredDaysTwoMonths) ||
      ($selectedOptionID === 'discount-code-3' && totalDays < discountRequiredDaysSixMonths)) {
      isValid = false
    }

    return isValid
  }

  const showDiscountError = () => {
    if ($selectedOptionID === 'discount-code-1') {
      $discountOneMonthError.removeClass('hidden')
      $discountTwoMonthsError.addClass('hidden')
      $discountSixMonthsError.addClass('hidden')
    } else if ($selectedOptionID === 'discount-code-2') {
      $discountOneMonthError.addClass('hidden')
      $discountSixMonthsError.addClass('hidden')
      $discountTwoMonthsError.removeClass('hidden')
    } else if ($selectedOptionID === 'discount-code-3') {
      $discountOneMonthError.addClass('hidden')
      $discountTwoMonthsError.addClass('hidden')
      $discountSixMonthsError.removeClass('hidden')
    }
  }

  const hideUnbookableDiscountOption = (checkInDate) => {
    const availableDates = $availableBookingSlot.attr('data-enables').split(';')

    if (!isAllDaysAvailable(checkInDate, availableDates, discountRequiredDaysOneMonth)) {
      $discountOneMonthOption.parent().addClass('hidden')
      // hide discount area when even one month discount is not available
      $noDiscountOption.parent().addClass('hidden')
      $discountAreaTitle.addClass('hidden')
    } else {
      $noDiscountOption.parent().removeClass('hidden')
      $discountAreaTitle.removeClass('hidden')
      $discountOneMonthOption.parent().removeClass('hidden')
    }

    if (!isAllDaysAvailable(checkInDate, availableDates, discountRequiredDaysTwoMonths)) {
      $discountTwoMonthsOption.parent().addClass('hidden')
    } else { $discountTwoMonthsOption.parent().removeClass('hidden') }

    if (!isAllDaysAvailable(checkInDate, availableDates, discountRequiredDaysSixMonths)) {
      $discountSixMonthsOption.parent().addClass('hidden')
    } else { $discountSixMonthsOption.parent().removeClass('hidden') }
  }

  $optionsForDiscount.on('change', () => {
    Object.values($tips).forEach((tip) => { tip.addClass('hidden') })

    $selectedOptionID = $(event.currentTarget).attr('id')

    Object.values($tips).forEach((tip) => {
      const tipID = tip.attr('id')

      if (`${$selectedOptionID}-tip` === tipID) {
        tip.removeClass('hidden')
      }
    })

    updatePromotionVal()
    fillPromotionNeededDays()
    $bookButton.prop('disabled', false)
    pricingCalculator.calculators.forEach(calculator => calculator.update())
    displayInformationNotices()
  })

  $checkIn.on('change', () => {
    if ($checkIn.val() === '') {
      displayPromotionOptions(false)
    } else {
      displayPromotionOptions(true)
    }

    hideUnbookableDiscountOption($checkIn.val())
  })

  $checkOut.on('change', () => {
    $bookButton.prop('disabled', false)
  })

  $bookButton.on('click', (e) => {
    if (promotionIsValid() === false) {
      e.preventDefault()
      showDiscountError()
      $bookButton.attr('disabled', true)
    }
  })

  displayPromotionOptions(false)
}

module.exports = { isAllDaysAvailable, discountOptions }
