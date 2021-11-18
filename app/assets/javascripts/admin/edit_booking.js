// ActiveAdmin edit booking

$(document).ready(() => {
  const $form = $('#edit_order')
  const $note = $('#order_note')

  $form.on('submit', () => {
    if ($note.val() === '') {
      const alert = window.alert
      alert('Please update Reasons for Adjustments (Damage fee) or key in N/A if not applicable.')
      return false
    }
    return true
  })
})
