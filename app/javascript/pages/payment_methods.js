// Payment Method

export default class PaymentMethod {
}

export class StripeTokenFetcher {
  constructor(el) {
    this.$form = $(el)
    this.$submit = this.$form.find('[type=submit]')

    this.$cardNumber = this.$form.find('[data-stripe="number"]')
    this.$cardNumberParent = this.$cardNumber.parent('.form-group')
    this.$cardHelper = $('<span class="help-block"></span>')
    this.$cardHelper.insertAfter(this.$cardNumber)

    this.$cardExpiry = this.$form.find('[data-stripe="exp"]')
    this.$cardExpiryParent = this.$cardExpiry.parent('.form-group')
    this.$expiryHelper = $('<span class="help-block"></span>')
    this.$expiryHelper.insertAfter(this.$cardExpiry)

    this.$cardCVC = this.$form.find('[data-stripe="cvc"]')
    this.$cardCVCParent = this.$cardCVC.parent('.form-group')
    this.$cvcHelper = $('<span class="help-block"></span>')
    this.$cvcHelper.insertAfter(this.$cardCVC)


    this.$form.on('submit', (ev) => {
      ev.preventDefault()
      this.fetchToken()
      return false
    })
  }

  fetchToken() {
    this.$submit.prop('disabled', true)
    this.resetAjaxErrors()
    Stripe.card.createToken(this.$form, (status, response) => {
      this.$submit.prop('disabled', false)

      if (response.error) {
        this.handleStripeError(response)
        return
      }

      const token = response.id
      const identifier = `**** **** **** ${response.card.last4}`
      const expiry = new Date(`${response.card.exp_year}/${response.card.exp_month}/1`)

      $.post(GlobalConfig.Path.PaymentMethod, {
        token,
        identifier,
        expiry_date: expiry
      })
        .done((data) => { location.href = data.path })
        .fail((jqXHR) => { location.href = jqXHR.responseJSON.path })
    })
  }

  handleStripeError(response) {
    if (response.error.type !== 'card_error') {
      this.$cardNumberParent.addClass('has-error')
      this.$cardHelper.text(response.error.message)
    }

    switch (response.error.code) {
      case 'invalid_number':
      case 'incorrect_number':
      case 'card_declined':
        this.$cardNumberParent.addClass('has-error')
        this.$cardHelper.text(response.error.message)
        break
      case 'invalid_expiry_month':
      case 'invalid_expiry_year':
      case 'expired_card':
        this.$cardExpiryParent.addClass('has-error')
        this.$expiryHelper.text(response.error.message)
        break
      case 'invalid_cvc':
      case 'incorrect_cvc':
        this.$cardCVCParent.addClass('has-error')
        this.$cvcHelper.text(response.error.message)
        break
      default:
    }
  }

  resetAjaxErrors() {
    this.$cardNumberParent.removeClass('has-error')
    this.$cardHelper.text('')

    this.$cardExpiryParent.removeClass('has-error')
    this.$expiryHelper.text('')

    this.$cardCVCParent.removeClass('has-error')
    this.$cvcHelper.text('')
  }
}
