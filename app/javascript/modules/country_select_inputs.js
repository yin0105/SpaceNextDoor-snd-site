class CountrySelectInput {
  constructor(element) {
    $(element).find('select').select2()
  }
}

export default class CountrySelectInputs {
  constructor() {
    this.inputs = []
    this.$countrySelects = $('.country_select')
    this.$countrySelects.each((_index, item) => {
      this.register(item)
    })
  }

  register(element) {
    const input = new CountrySelectInput(element)
    this.inputs.push(input)
  }
}
