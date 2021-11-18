/**
 * Stripe
 */

import { fromEvent } from 'rxjs'
import { delay, throttleTime } from 'rxjs/operators'

export const stripe = Stripe

// Setup Stripe API
Stripe.setPublishableKey(GlobalConfig.Stripe.Key)

function validate(method, value, $el) {
  const validateMethod = $.payment[`validate${method}`]
  if (validateMethod.apply($.payment, value)) {
    $el.removeClass('has-error')
  } else {
    $el.addClass('has-error')
  }
}

const ValidatorCheckSpeed = 300
const ValidatorCheckDelay = 300
export class CardFormatter {
  constructor() {
    this.$cardNumber = $('input[data-card-number=true]')
    this.$expiration = $('input[data-card-expiry=true]')
    this.$cvc = $('input[data-card-cvc=true]')

    this.$cardNumber.payment('formatCardNumber')
    this.$expiration.payment('formatCardExpiry')
    this.$cvc.payment('formatCardCVC')

    this.setupValidator()
  }

  setupValidator() {
    this.$cardNumber.each((index, $el) => {
      const parent = $($el).parent('.form-group')
      fromEvent($el, 'keydown')
        .pipe(throttleTime(ValidatorCheckSpeed))
        .pipe(delay(ValidatorCheckDelay))
        .subscribe(() => {
          validate('CardNumber', [$el.value], parent)
        })
    })

    this.$expiration.each((index, $el) => {
      const parent = $($el).parent('.form-group')
      fromEvent($el, 'keydown')
        .pipe(throttleTime(ValidatorCheckSpeed))
        .pipe(delay(ValidatorCheckDelay))
        .subscribe(() => {
          validate('CardExpiry', $el.value.split(' / '), parent)
        })
    })

    this.$cvc.each((index, $el) => {
      const parent = $($el).parent('.form-group')
      fromEvent($el, 'keydown')
        .pipe(throttleTime(ValidatorCheckSpeed))
        .pipe(delay(ValidatorCheckDelay))
        .subscribe(() => {
          validate('CardCVC', [$el.value], parent)
        })
    })
  }
}
