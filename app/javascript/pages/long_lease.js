import PricingCalculator from '../modules/pricing_calculator'
import displayInformationNotices from '../modules/display_information_notices'

const oneDayInMilliseconds = 24 * 60 * 60 * 1000

const getDate = (startAt, days) => {
  const newCheckOut = startAt + (oneDayInMilliseconds * days)
  const year = new Date(newCheckOut).getFullYear()
  const month = new Date(newCheckOut).getMonth()
  const day = new Date(newCheckOut).getDate()

  return [year, month, day]
}

const longLease = () => {
  const $checkIn = $('.pricing-calculator__from')
  const $checkOut = $('.pricing-calculator__to')
  const availabeDates = $('.space__booking-datepicker .flatpickr-input').attr('data-enables')
  const $space = $('#space')
  const autoMonth = Number($('.check-in').data('automonth')) - 1

  // _information
  if (availabeDates && availabeDates.length === 0) {
    $('.space__booking-datepicker .flatpickr-input').prop('disabled', true)
    $('.space__booking-toggle-long-term, .space__booking-book, .space__booking-not-yet-charged').remove()
    $('.space__booking-unavailable-notice').removeClass('hidden')
  }

  $('.flatpickr-input').on('change', () => {
    if ($space) {
      displayInformationNotices()
    }
  })

  const pricingCalculator = new PricingCalculator()
  const $form = $('.space__pricing-calculator')
  const $checkbox = $('#long_term_mark')
  const $minDays = $('.fa-calendar').attr('data-min-days')
  const $minDaysNotice = $('.space__min-days-notice')

  $checkbox.on('click', () => {
    if ($checkbox.prop('checked') && autoMonth) {
      const [year, month, day] = getDate(Date.parse($checkIn.val()), autoMonth)
      /* eslint no-underscore-dangle: ["error", { "allow": ["_flatpickr"] }] */
      $checkOut[0]._flatpickr.setDate(new Date(`${year}/${month + 1}/${day}`))
      pricingCalculator.calculators.forEach(calculator => calculator.update())
      displayInformationNotices()
    }

    $checkOut.prop('disabled', $checkbox.prop('checked'))
    $minDaysNotice.toggleClass('hidden')
  })

  $checkIn.on('change', () => {
    const checkIn = Date.parse($checkIn.val())
    const nowTime = Date.parse(new Date())
    const aMonth = oneDayInMilliseconds * 30
    if (checkIn - nowTime <= aMonth) {
      $('.space__booking-datepicker-over-month-error').addClass('hidden')
      $('.space__booking-book > button').attr('disabled', false)
    }
  })

  $checkIn.on('change', () => {
    const checkIn = $checkIn.val()
    const $startDays = $('.space__booking-toggle-long-term').attr('data-start-days').split(';')
    const nextOrderStart = $startDays.filter(day => Date.parse(day) > Date.parse(checkIn))[0]
    const daysToEnd = ((Date.parse(nextOrderStart) - Date.parse(checkIn)) / 86400000)

    if (!nextOrderStart || daysToEnd > autoMonth || $startDays[0].length === 0) {
      $checkbox.prop('disabled', false)
    } else {
      $checkbox.prop('checked', false)
      $checkbox.prop('disabled', true)
      $checkOut.prop('disabled', $checkbox.prop('checked'))
      $checkOut[0]._flatpickr.clear()
    }

    if ($minDays) {
      const [year, month, day] = getDate(Date.parse($checkIn.val()), ($minDays - 1))
      /* eslint no-underscore-dangle: ["error", { "allow": ["_flatpickr"] }] */
      $checkOut[0]._flatpickr.setDate(new Date(`${month + 1}/${day}/${year}`))
      pricingCalculator.calculators.forEach(calculator => calculator.update())
      displayInformationNotices()
    }
  })

  if ($space) {
    $form.on('submit', (e) => {
      $space.find('.order-date-inputs').removeAttr('disabled')

      if ($checkIn.val().length === 0) {
        $('.space__booking-datepicker-blank-error').removeClass('hidden')
        e.preventDefault()
      }
    })
  }

  $('.space__booking-book > button').on('click', (e) => {
    const checkIn = Date.parse($checkIn.val())
    const nowTime = Date.parse(new Date())
    const aMonth = oneDayInMilliseconds * 30
    if (checkIn - nowTime > aMonth) {
      e.preventDefault()
      $('.space__booking-datepicker-over-month-error').removeClass('hidden')
      $('.space__booking-book > button').attr('disabled', true)
    }
  })

  // new_order
  const $order = $('#order-input-form')

  if ($order) {
    $order.find('.order-date-inputs').prop('disabled', true)
  }

  $order.on('submit', () => {
    $('.order-date-inputs').removeAttr('disabled')
  })
}

export default longLease
