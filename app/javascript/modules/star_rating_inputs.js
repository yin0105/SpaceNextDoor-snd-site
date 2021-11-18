class StarRating {
  constructor(element) {
    this.$input = $(element)

    this.$input.find('span[data-value]').click((e) => {
      const value = $(e.target).data('value')
      this.$input.find('input').val(value)
      this.$input.attr('data-value', value)
    })
  }
}

export default class StarRatings {
  constructor() {
    this.inputs = []
    this.$imageUploadInputs = $('.star-rating-input')
    this.$imageUploadInputs.each((_index, item) => {
      this.register(item)
    })
  }

  register(element) {
    const input = new StarRating(element)
    this.inputs.push(input)
  }
}
