/**
 * Verification Code
 */

import { fromEvent } from 'rxjs'
import { delay } from 'rxjs/operators'

const VALIDATE_SPEED = 300

class VerificationItem {
  constructor($el) {
    this.$el = $el
    this.$parent = this.$el.parent()
    this.$button = $el.next('button')

    this.type = $el.data('verification')

    this.$helper = $('<span class="help-block"></span>')
    this.$parent.append(this.$helper)
    this.getIdentity()

    fromEvent(this.$el, 'keydown').pipe(delay(VALIDATE_SPEED)).subscribe(() => { this.toggleVerifyButton() })
    fromEvent(this.$button, 'click').subscribe(() => { this.verifyCode() })
  }

  code() {
    return this.$el.val()
  }

  getIdentity() {
    const url = new URL(window.location.href)
    this.identity = url.searchParams.has('identity') ? 'host' : null
  }

  isValid() {
    const lengthEnough = this.code().length >= GlobalConfig.VerificationCodeDigit
    const isDigit = /[0-9]+/.test(this.code())

    return lengthEnough && isDigit
  }

  toggleVerifyButton() {
    this.$button.prop('disabled', !this.isValid())
    if (this.isValid()) {
      this.clearError()
    } else {
      this.displayError()
    }
  }

  verifyCode() {
    $.post(GlobalConfig.Path.VerificationVerify, {
      type: this.type,
      code: this.code(),
      identity: this.identity
    }).done((response) => { this.onSuccess(response) })
  }

  onSuccess(response) {
    if (response.error) {
      this.displayError(response.error.message)
    } else {
      window.location.href = response.path
    }
  }

  displayError(message) {
    this.$parent.addClass('has-error')
    this.$helper.text(message)
  }

  clearError() {
    this.$parent.removeClass('has-error')
    this.$helper.text('')
  }
}

export default class VerificationCode {
  constructor() {
    this.$verifications = $('[data-verification]')
    this.verifications = []

    this.$verifications.each((index, item) => {
      this.verifications.push(new VerificationItem($(item)))
    })
  }
}
