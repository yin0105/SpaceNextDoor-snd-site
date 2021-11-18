// Facebook

export default class Facebook {
  constructor() {
    window.fbAsyncInit = () => {
      FB.init({
        appId: GlobalConfig.Facebook.AppId,
        xfbml: true,
        version: 'v2.8'
      })
      FB.AppEvents.logPageView()
    }

    this.$shareLinks = $('a[data-facebook-share]')

    this.setupShareButton()
  }

  setupShareButton() {
    this.$shareLinks.on('click', (e) => {
      e.preventDefault()

      FB.ui({
        method: 'share',
        href: $(e.target).closest('a').attr('href')
      })
    })
  }
}
