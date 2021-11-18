$(document).ready(() => {
  function getYearList() {
    const maxYear = new Date().getFullYear()
    const minYear = new Date('2017').getFullYear()
    const yearRange = (maxYear - minYear) + 1
    return Array(yearRange)
            .fill('')
            .map((_, idx) => maxYear - idx)
  }

  $('#financial_start_year').select2({
    data: getYearList()
  })

  const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  $('#financial_start_month').select2({
    placeholder: 'Please select the month',
    data: monthNames
  })
})
