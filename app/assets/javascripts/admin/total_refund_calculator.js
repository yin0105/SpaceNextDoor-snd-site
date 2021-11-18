// Total Refund Calculator

$(document).ready(() => {
  const parsePrice = string => Number(string.replace(/[^-\d.]+/g, '')) || 0
  const formatPrice = price => parseFloat(price).toFixed(2)

  const $deposit = $('.total-refund-calculator__deposit')
  const $refund = $('.total-refund-calculator__refund')
  const $damageFee = $('#order_damage_fee')
  const $addFee = $('#order_add_fee')
  const $total = $('.total-refund-calculator__total')

  const deposit = parsePrice($deposit.text())
  const refund = parsePrice($refund.text())

  const displayPrice = price => `$${formatPrice(price)}`

  const updateDamageInput = (damageFee) => {
    $damageFee.val(formatPrice(damageFee))
  }

  const updateAddInput = (addFee) => {
    $addFee.val(formatPrice(addFee))
  }

  const displayDeposit = (damageFee) => {
    $deposit.text(displayPrice(deposit - damageFee))
  }

  const displayRefund = (addFee) => {
    $refund.text(displayPrice(refund - addFee))
  }

  const displayTotal = (total) => {
    $total.text(displayPrice(total))
  }

  const update = () => {
    const damageFee = $damageFee.val() ? parsePrice($damageFee.val()) : 0
    const addFee = $addFee.val() ? parsePrice($addFee.val()) : 0
    const total = (deposit + refund) - (damageFee + addFee)

    updateDamageInput(damageFee)
    updateAddInput(addFee)

    displayDeposit(damageFee)
    displayRefund(addFee)
    displayTotal(total)
  }

  const trackingDateChanged = () => {
    $damageFee.on('change', update)
    $addFee.on('change', update)
  }

  update()
  trackingDateChanged()
})
