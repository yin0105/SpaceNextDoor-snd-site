
function startEndDates(start, end) {
  const startDate = Date.parse(start)
  const endDate = Date.parse(end)

  return [startDate, endDate]
}

function isOverThanMonth(startDate, endDate) {
  const oneDayInMilliseconds = 24 * 60 * 60 * 1000
  const autoMonth = Number($('.check-in').data('automonth')) - 1
  const [start, end] = startEndDates(startDate, endDate)

  if (end - start >= oneDayInMilliseconds * autoMonth) {
    return true
  }
  return false
}

function update(startDate, endDate) {
  const $oneMonthChargeNotice = $('.space__booking-notice-message')

  if (isOverThanMonth(startDate, endDate)) {
    $oneMonthChargeNotice.attr('hidden', false)
  } else {
    $oneMonthChargeNotice.attr('hidden', true)
  }
}

const displayInformationNotices = () => {
  const $checkIn = $('.pricing-calculator__from').val()
  const $checkOut = $('.pricing-calculator__to').val()

  update($checkIn, $checkOut)
}

export default displayInformationNotices
