class NotificationSelectInput {
  constructor(element) {
    $(element).find('select').select2({
      width: '100%',
      minimumInputLength: 1,
      ajax: {
        url: '/admin/notifications/query_users',
        type: 'get',
        data: params => ({
          name: params.term
        }),
        processResults: data => ({
          results: data
        })
      }
    })
  }
}

export default class NotificationForm {
  constructor() {
    this.widget = []
    this.$notificationSelect = $('#notification_query_users_input')
    this.$queryUsers = $('#notification_query_users')
    this.$personalType = $('#notification_notify_type_personal')
    this.$notifyTypeInput = $('#notification_notify_type_input')
    this.$notifyType = this.$notifyTypeInput.find("input[name='notification[notify_type]']")
    this.currentNotifyType = this.$notifyTypeInput.find("input[name='notification[notify_type]']:checked").val()

    this.register(this.$notificationSelect)

    this.displaySelectRendered()
    this.trackingSelectRendered()
  }

  register(element) {
    const input = new NotificationSelectInput(element)
    this.widget.push(input)
  }

  trackingSelectRendered() {
    this.$queryUsers.change(() => { this.assignNotifyType() })
    this.$notifyType.on('click', (e) => { this.updateNotifyType(e) })
  }

  assignNotifyType() {
    this.$personalType.prop('checked', true)
    this.currentNotifyType = this.$personalType.val()
    this.displaySelectRendered()
  }

  updateNotifyType(event) {
    this.currentNotifyType = event.target.value
    this.displaySelectRendered()
  }

  displaySelectRendered() {
    this.$selectRendered = this.$notificationSelect.find('ul.select2-selection__rendered')
    this.$selectChoice = this.$selectRendered.find('.select2-selection__choice')

    if (this.currentNotifyType === 'personal') {
      this.$selectChoice.removeClass('hidden')
    } else {
      this.$selectChoice.addClass('hidden')
    }
  }
}
