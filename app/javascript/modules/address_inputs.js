/**
 * Address Input
 */

import _ from 'lodash'
import { fromEvent } from 'rxjs'
import { delay } from 'rxjs/operators'

class AddressInput {
  constructor(element) {
    this.$inputGroup = $(element)
    this.$countryInput = this.$inputGroup.find('[data-address=country]')
    this.$postalCodeInput = this.$inputGroup.find('[data-address=postal_code]')
    this.$cityInput = this.$inputGroup.find('[data-address=city]')
    this.$areaInput = this.$inputGroup.find('[data-address=area]')
    this.$streetAddressInput = this.$inputGroup.find('[data-address=street-address]')
    this.$unitInput = this.$inputGroup.find('[data-address=unit]')

    this.initCountryInput()
    this.initCityInput()
    this.initAreaInput()
    this.bindFormSubmitPreventer()
  }

  bindFormSubmitPreventer() {
    this.$inputGroup.parents('form').on('submit', () => {
      if (this.$countryInput.prop('value') === '' ||
        this.$postalCodeInput.prop('value') === '' ||
        this.$areaInput.prop('value') === '' ||
        this.$streetAddressInput.prop('value') === '' ||
        this.$unitInput.prop('value') === '') {
        const notify = window.alert
        notify('Please fill all address fields')
        return false
      }
      return true
    })
  }

  initCountryInput() {
    this.$countryInput.select2({
      placeholder: 'Country',
      data: this.getCountrySelections()
    })
    fromEvent(this.$countryInput, 'change')
      .pipe(delay(50))
      .subscribe((e) => {
        const countryCode = e.target.value
        const cityCode = this.$cityInput.val()
        this.setCityInputFor(countryCode)
        this.setAreaInputFor(countryCode, cityCode)
      })
  }

  initCityInput() {
    this.setCityInputFor(this.$countryInput.val())
    fromEvent(this.$cityInput, 'change')
      .pipe(delay(50))
      .subscribe((e) => {
        const cityCode = e.target.value
        const countryCode = this.$countryInput.val()
        this.setAreaInputFor(countryCode, cityCode)
      })
  }

  setCityInputFor(countryCode) {
    const cityInputConfig = {
      placeholder: 'City'
    }

    if (countryCode) {
      this.$cityInput.prop('display', 'none')
      this.$cityInput.select2({
        ...cityInputConfig,
        data: this.getCitySelectionsFor(countryCode)
      })
    } else {
      this.$cityInput.select2(cityInputConfig)
      this.$cityInput.prop('disabled', false)
    }

    // Singapore only has one city, select it by default
    if (countryCode === 'SGP') {
      this.$cityInput.val('SGP-SGP').trigger('change')
    }

    // Show postal code input for Singapore only
    if (countryCode === 'SGP') {
      this.$postalCodeInput.css('display', 'inline-block')
    } else {
      this.$postalCodeInput.css('display', 'none')
    }

    const availableValues = this.getCitySelectionsFor(countryCode).map(data => data.id)
    const currentValue = this.$cityInput.val()
    if (!availableValues.includes(currentValue)) {
      this.$cityInput.val('').trigger('change')
    }

    // For Singapore, hide the city section
    if (countryCode === 'SGP') {
      this.$cityInput.next('.select2-container').css('display', 'none')
    } else {
      this.$cityInput.next('.select2-container').css('display', 'inline-block')
    }
  }

  initAreaInput() {
    this.setAreaInputFor(this.$countryInput.val(), this.$cityInput.val())
  }

  setAreaInputFor(countryCode, cityCode) {
    const areaInputConfig = {
      placeholder: 'Area'
    }

    if (countryCode && cityCode) {
      this.$areaInput.prop('disabled', false)
      this.$areaInput.select2({
        ...areaInputConfig,
        data: this.getAreaSelectionsFor(countryCode, cityCode)
      })
    } else {
      this.$areaInput.select2(areaInputConfig)
      this.$areaInput.prop('disabled', true)
    }

    const availableValues = this.getAreaSelectionsFor(countryCode, cityCode)
      .map(data => data.id)
    const currentValue = this.$areaInput.val()
    if (!availableValues.includes(currentValue)) {
      this.$areaInput.val('').trigger('change')
    }

    // For Singapore, hide the area section
    // For custom's needs, display area section again, 2019.05.21
    if (countryCode === 'SGP') {
      // Change the input name to leave this field nil for backend
      // this.$areaInput.attr('name', `_${this.$areaInput.attr('name')}`);
      // this.$areaInput.next('.select2-container').css('display', 'none');
    } else {
      this.$areaInput.attr('name', this.$areaInput.attr('name').replace(/^_+/, ''))
      this.$areaInput.next('.select2-container').css('display', 'inline-block')
    }
  }

  getCountrySelections() {
    if (this.countrySelections) return this.countrySelections

    const regions = GlobalConfig.Regions
    this.countrySelections = Object.keys(regions).map(countryCode => ({
      id: countryCode,
      text: regions[countryCode].name
    }))

    return this.countrySelections
  }

  getCitySelectionsFor(countryCode) {
    if (!this.citySelections) this.citySelections = {}
    if (this.citySelections[countryCode]) return this.citySelections[countryCode]

    const regions = GlobalConfig.Regions
    const cities = _.get(regions, [countryCode, 'cities'], {})
    this.citySelections[countryCode] = Object.keys(cities).map(cityCode => ({
      id: `${countryCode}-${cityCode}`,
      text: cities[cityCode].name
    }))

    return this.citySelections[countryCode]
  }

  getAreaSelectionsFor(countryCode, cityCode) {
    if (!this.areaSelections) this.areaSelections = {}
    if (this.areaSelections[cityCode]) return this.areaSelections[cityCode]

    const regions = GlobalConfig.Regions
    const areas = _.get(regions, [countryCode, 'cities', cityCode.split('-').pop(), 'areas'], {})
    this.areaSelections[cityCode] = Object.keys(areas).map(areaCode => ({
      id: `${cityCode}-${areaCode}`,
      text: areas[areaCode].name
    }))

    return this.areaSelections[cityCode]
  }
}

export default class AddressInputs {
  constructor() {
    this.inputs = []
    this.$addressInputs = $('.address-input')
    this.$addressInputs.each((_index, item) => {
      this.register(item)
    })
  }

  register(element) {
    const input = new AddressInput(element)
    this.inputs.push(input)
  }
}
