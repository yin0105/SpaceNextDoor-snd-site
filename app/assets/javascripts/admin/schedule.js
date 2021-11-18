jQuery(() => {
  $('.perform-admin-schedule').on('click', (e) => {
    e.preventDefault()

    ActiveAdmin.modal_dialog('Perform this schedule ?', {}, () => {
      const { requestPath } = $(e.target).data()

      $.ajax({
        type: 'POST',
        url: requestPath
      })
      .then(() => { window.location.reload() })
    })
  })
})
