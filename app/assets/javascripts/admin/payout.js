jQuery(() => {
  $('.mark-paid-admin').on('click', (e) => {
    e.preventDefault()

    ActiveAdmin.modal_dialog('', { 'Mark Paid At': 'datepicker' }, (inputs) => {
      const date = inputs['Mark Paid At']
      const { requestPath } = $(e.target).data()

      if (!date) return

      $.ajax({
        type: 'PATCH',
        url: requestPath,
        data: { actual_paid_at: date }
      }).then(() => { window.location.reload() })
    })
  })
})
