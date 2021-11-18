jQuery(() => {
  $('.cancel-long-term-admin').on('click', (e) => {
    e.preventDefault()

    ActiveAdmin.modal_dialog('', { 'Termination date': 'datepicker' }, (inputs) => {
      const date = inputs['Termination date']
      const { requestPath } = $(e.target).data()

      if (!date) return

      $.ajax({
        type: 'DELETE',
        url: requestPath,
        data: { early_check_out: date }
      }).then(() => { window.location.reload() })
    })
  })
})
