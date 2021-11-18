// Pricing Calculator

const parsePrice = (string) => {
  const RULE = /[0-9.]+/
  const matches = string.match(RULE)
  return parseFloat(matches[0])
}

const formatPrice = price => `$${parseFloat(price).toFixed(2)}`
const DISCOUNT_CODES = { 'discount-code-1': 1, 'discount-code-2': 2, 'discount-code-3': 3 }

class Calculator {
  constructor($calculator) {
    this.$calculator = $calculator

    this.$price = this.$calculator.find('.pricing-calculator__price')
    this.$from = this.$calculator.find('input.pricing-calculator__from[name]')
    this.$to = this.$calculator.find('input.pricing-calculator__to[name]')
    this.$days = this.$calculator.find('.pricing-calculator__days')
    this.$rent = this.$calculator.find('.pricing-calculator__rent')
    this.$serviceFee = this.$calculator.find('.pricing-calculator__service-fee')
    this.$deposit = this.$calculator.find('.pricing-calculator__deposit')
    this.$discount = this.$calculator.find('.pricing_calculator__promotion')
    this.$discountCode = this.$calculator.find('.space__booking-promotion-val')
    this.$discountItem = this.$calculator.find('.space__booking-promotion')
    this.$total = this.$calculator.find('.pricing-calculator__total')
    this.$insuranceSelector = this.$calculator.find('.pricing-calculator__insurance-selector')
    this.$insuranceOption = this.$calculator.find('.pricing-calculator__insurance-option')
    this.$insurance = this.$calculator.find('.pricing-calculator__insurance')
    this.price = parsePrice(this.$price.text())
    this.rent = this.price
    this.coverage = ''
    this.premium = 0
    this.serviceFee = this.rent * GlobalConfig.GSFRate
    this.deposit = this.rent * GlobalConfig.DepositDays

    if (this.$insurance.length !== 0) {
      this.$insuranceSelector.attr('hidden', true)
    }

    this.total = this.rent + this.serviceFee + this.deposit
    this.discount = 0
    this.$discountItem.addClass('hidden')

    this.trackingDateChanged()
  }

  trackingDateChanged() {
    this.$from.change(() => { this.update() })
    this.$to.change(() => { this.update() })
    this.$insuranceOption.change(() => { this.update() })
  }

  update() {
    const from = new Date(this.$from.val())
    const to = new Date(this.$to.val())
    const daysInMiliseconds = Math.abs(to - from)

    if (Number.isNaN(daysInMiliseconds)) {
      return
    }

    if (this.$insurance.length !== 0) {
      this.$insuranceSelector.attr('hidden', false)
    }

    const days = Math.floor(daysInMiliseconds / 86400 / 1000) + 1

    this.updateDays(days)
    this.updateRent(days)
    this.updateServiceFee()
    this.updateInsurance(days)
    this.updateDiscount()
    this.updateTotal()
  }

  updateDays(days) {
    const postfix = days > 1 ? 'days' : 'day'
    this.$days.text(`${days} ${postfix}`)
  }

  updateRent(days) {
    this.rent = days * this.price
    this.$rent.text(formatPrice(this.rent))
  }

  updateDiscount() {
    const discountCode = this.$discountCode.prop('value')
    if (discountCode === '') {
      this.discount = 0
      this.$discountItem.addClass('hidden')
    } else {
      const period = DISCOUNT_CODES[discountCode]
      if (period === 3) {
        this.discount = this.rent / 2
      } else {
        this.discount = (this.deposit + (this.deposit * GlobalConfig.GSFRate)) * period
      }
      this.$discountItem.removeClass('hidden')
    }
    this.$discount.text(`-${formatPrice(this.discount)}`)
  }

  updateServiceFee() {
    this.serviceFee = this.rent * GlobalConfig.GSFRate
    this.$serviceFee.text(formatPrice(this.serviceFee))
  }

  updateInsurance(days) {
    if (this.$insuranceOption.length === 0) {
      return
    }

    const months = Math.ceil(days / 30)

    this.updatePremium()

    this.insurance = months * parsePrice((this.premium).toString())
    this.$insurance.text(formatPrice(this.insurance))
  }

  updatePremium() {
    this.coverage = GlobalConfig.InsuranceOptions[this.$insuranceOption.val()]
    this.premium = this.coverage.premium / 100
  }

  updateTotal() {
    this.total = (this.rent + this.deposit + this.serviceFee) - this.discount

    if (this.$insurance.length !== 0) {
      this.total += this.insurance
    }

    this.$total.text(formatPrice(this.total))
  }
}

class PricingCalculator {
  constructor() {
    this.calculators = []
    this.$calculators = $('.pricing-calculator')
    this.$calculators.each((_, el) => { this.calculators.push(new Calculator($(el))) })
  }
}

export default PricingCalculator
