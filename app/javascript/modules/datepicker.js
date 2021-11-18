/**
 * Date Picker
 *
 * Base on `Flatpickr`
 */

import Flatpickr from '../../../vendor/assets/javascripts/flatpickr'

const isAfterToday = (dateString) => {
  const date = new Date(dateString)
  const today = new Date()
  return date > today
}

export default class DatePicker {
  constructor() {
    this.pickers = []
    this.$datePickers = $('[data-datepicker]')
    this.$datePickers.each((_, item) => {
      const mode = item.dataset.mode || 'single'
      const inline = item.dataset.inline || false
      const { minDate } = item.dataset
      const defaultDate = item.value

      const options = {
        altInput: true,
        mode,
        inline,
        minDate
      }

      const enable = item.dataset.enables || false
      const disable = item.dataset.disables || false
      const between = item.dataset.between || false

      if (enable === 'booked_up') {
        options.enable = [() => false]
      } else if (!!enable === true) {
        options.enable = enable.split(';')
      }

      if (!!between === true) {
        const range = between.split('..')
        options.enable = options.enable || []
        options.enable.push({ from: range[0], to: range[1] })
      }

      if (!!disable === true) {
        options.disable = disable.split(';')
      }

      if (!!defaultDate === true) {
        options.defaultDate = defaultDate
      }

      const picker = new Flatpickr(item, options)
      picker.setDate(item.value)

      if (!!enable === true && isAfterToday(options.enable[0]) && !defaultDate) {
        picker.jumpToDate(options.enable[0])
      }

      this.pickers.push(picker)
    })
  }

  destroy() {
    this.pickers.forEach(picker => picker.destroy())
  }
}
