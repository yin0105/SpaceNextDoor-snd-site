function getSelectOption() {
  const $insuranceOption = $('#insurance_type')
  const selectOption = $insuranceOption.find(':selected').text()

  return selectOption
}

function preview() {
  const $previewBlock = $('#js-preview-block')
  const $displayBlock = $('.js-display-block')
  const $paymentInsurance = $('.js-last-payment-insurance').text()
  const $orderInsurance = $('.js-current-order-insurance').text()

  if ($paymentInsurance === getSelectOption() && $orderInsurance === getSelectOption()) {
    $displayBlock.addClass('hidden')
  } else {
    $previewBlock.text(getSelectOption())
    $displayBlock.removeClass('hidden')
  }
}

function checkOption(event) {
  const e = event
  const $orderInsurance = $('.js-current-order-insurance').text()
  const confirmContent = 'New insurance option will be updated in your next renewal. Are you sure?'
  const alertContent = "The insurance coverage you've chosen is the same as current. Please choose again."

  if ($orderInsurance === getSelectOption()) {
    e.preventDefault()
    alert(alertContent) // eslint-disable-line no-alert
  } else if (confirm(confirmContent)) { // eslint-disable-line no-alert
    e.returnValue = true
  } else {
    e.preventDefault()
  }
}

export const editInsurance = () => {
  const $insuranceOption = $('#insurance_type')
  const $confirmBtn = $('.update-insurance .js-confirm-btn')

  $insuranceOption.on('select2:select', preview)
  $confirmBtn.on('click', checkOption)
}

export default editInsurance
