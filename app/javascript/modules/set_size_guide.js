const setSizeGuide = () => {
  $('.js-size-open').on('click touch', (e) => {
    const target = e.currentTarget.getAttribute('data-active')
    $('#size-guide-popup .active').removeClass('active')
    $(`#size-guide-popup .${target}_item`).addClass('active')
  })

  $('.js-size-guide-button').on('click touch', () => {
    $('#size-guide-popup').modal('toggle')
  })
}

export default setSizeGuide
