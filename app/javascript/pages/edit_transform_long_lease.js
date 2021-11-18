// Edit transform long lease

export const editTransformLongLease = () => {
  const $confirmBtn = $('.edit-transform-long-lease .js-confirm-btn')
  const renewalDate = $('.renewal_date').text()
  const confirmContent = `You are requesting for your booking to be changed so that your storage period be extended automatically every 30 days until 16 days notice is given with effect from ${renewalDate}.`

  $confirmBtn.on('click', (e) => {
    if (confirm(confirmContent)) { // eslint-disable-line no-alert
      e.returnValue = true
    } else {
      e.preventDefault()
    }
  })
}

export default editTransformLongLease
