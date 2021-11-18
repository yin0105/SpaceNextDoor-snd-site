/*
  * This file rename from jquery.main.js that gives from designer of SND
  * Separate third party plugins includes:
  * smoothScroll, slick, mobileNav, fancyBox, videoBackground, tabs, accordion, jcf, jcf_range_input
  * Remove accordion plugin that unused
  * Remove fancyBox plugin that unused
  * Refactor function export for turbolinks:load
  * Rewrite initRangesValues function on file: jcf_range_slider.js
*/

// mobile menu init
export function initMobileNav() {
  $('body').mobileNav({
    menuActiveClass: 'nav-active',
    menuOpener: '.nav-opener',
    hideOnClickOutside: true,
    menuDrop: '.nav-drop'
  })
}

// slick init
export function initSlickCarousel() {
  if ($('.caption-slider').length > 0) {
    $('.caption-slider').slick({
      slidesToScroll: 1,
      rows: 0,
      arrows: false,
      fade: true,
      autoplay: true,
      pauseOnHover: false,
      autoplaySpeed: 4000
    })
  }
  if ($('.space-slider').length > 0) {
    $('.space-slider').slick({
      slidesToScroll: 1,
      slidesToShow: 4,
      rows: 0,
      prevArrow: '<a href="#" class="slick-prev"><i class="ico-arrow-left"></i></a>',
      nextArrow: '<a href="#" class="slick-next"><i class="ico-arrow-right"></i></a>',
      responsive: [{
        breakpoint: 1200,
        settings: {
          slidesToScroll: 1,
          slidesToShow: 4
        }
      }, {
        breakpoint: 1024,
        settings: {
          slidesToScroll: 1,
          slidesToShow: 3
        }
      }, {
        breakpoint: 768,
        settings: {
          slidesToScroll: 1,
          slidesToShow: 1
        }
      }]
    })
  }

  if ($('.testimonial-slider').length > 0) {
    $('.testimonial-slider').slick({
      slidesToScroll: 1,
      rows: 0,
      arrows: false,
      centerMode: true,
      centerPadding: '0px',
      focusOnSelect: true
    })
  }
}

// background video init
export function initBackgroundVideo() {
  $('.bg-video').backgroundVideo({
    activeClass: 'video-active'
  })
}

// content tabs init
export function initTabs() {
  $('.tabset').tabset({
    tabLinks: 'a',
    defaultTab: true
  })
}

// initialize custom form elements
export function initCustomForms() {
  jcf.replaceAll()
}
