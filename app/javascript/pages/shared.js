// Shared

import _ from 'lodash'

export default class SharedPage {
  constructor() {
    this.registrationModalToggle()
  }

  registrationModalToggle() {
    this.$signInModal = $('#signin-popup')
    this.$signUpModal = $('#signup-popup')

    this.handleRegistrationErrors()
  }

  handleRegistrationErrors() {
    this.$registrationForm = this.$signUpModal.find('form#new_user')
    this.$registrationForm.on('ajax:success', (event) => {
      const [response, status, xhr] = event.detail
      document.location.href = xhr.getResponseHeader('location')
    })
    this.$registrationForm.on('ajax:error', (response) => { this.markSignUpFormHasErrorFields(response.detail[0].errors) })
  }

  markSignUpFormHasErrorFields(errors) {
    let helpBlock
    let field
    const $closeModal = $('.close-modal')

    _.mapKeys(errors, (value, fieldName) => {
      field = this.$registrationForm.find(`.form-group.${fieldName}`)
      field.addClass('has-error')
      helpBlock = field.find('.help-block')
      helpBlock.text(errors[fieldName])
    })

    $closeModal.on('click', () => {
      field = this.$signUpModal.find('.form-group').removeClass('has-error')
      helpBlock = field.find('.help-block')
      helpBlock.text('')
    })
  }
}
