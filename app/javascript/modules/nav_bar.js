/**
 * nav_bar
 */
const initNavBar = () => {
  let showMenu = false
  const $navOpen = $('.nav-open')
  const $mobileMenu = $('.mobile-menu')
  const $wrapper = $('#wrapper')
  const displayMobileMenu = () => {
    if (showMenu) {
      $mobileMenu.removeClass('menu-open')
      $wrapper.toggleClass('menu-open')
      showMenu = false
    } else {
      $mobileMenu.addClass('menu-open')
      $wrapper.toggleClass('menu-open')
      showMenu = true
    }
  }

  $navOpen.click((e) => {
    e.preventDefault()
    displayMobileMenu()
  })
}

export default initNavBar
