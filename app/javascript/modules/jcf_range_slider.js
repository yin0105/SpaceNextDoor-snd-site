/*
 * Rewrite from main.js
 * Based on jcf and jcf_range_input
*/

const RANGE_VALUE_PATTERN = /([0-9.]+)\.{2,3}([0-9.]+)/

class RangeSlider {
  constructor($el) {
    this.$el = $el
    this.$input = $el.find("input[type='hidden']")
    this.$jcfInput = $el.find("input[type='range']")
    this.$jcfInstance = jcf.getInstance(this.$jcfInput)
    this.$jcfRangeHandles = $el.find('.jcf-range-handle')
    this.$jcfRangeHandleMin = $el.find('.jcf-index-1')
    this.$jcfRangeHandleMax = $el.find('.jcf-index-2')
    this.valueHolderStructure = $("<span class='value-holder'></span>")

    this.loadSettings()
    this.loadInitializeValue()
    this.createSlider()
  }

  loadInitializeValue() {
    const initializeValue = this.$input.val()
    const matches = initializeValue.match(RANGE_VALUE_PATTERN)
    if (matches) {
      this.initializeValue = [Number(matches[1]) || this.min, Number(matches[2]) || this.max]
    } else {
      this.setupUnmatchValue(initializeValue)
    }

    this.initJcfInputs()
  }

  setupUnmatchValue(initializeValue) {
    if (initializeValue) {
      this.initializeValue = [this.min, Number(initializeValue) || this.max]
    } else {
      this.initializeValue = [this.min, this.max]
    }
  }

  loadSettings() {
    this.min = this.$input.data('min')
    this.max = this.$input.data('max')
  }

  createSlider() {
    this.createValueHolder()
    this.displayHolder()

    this.$jcfInput.on('input change', () => {
      this.updateInput(this.$jcfInstance.values)
      this.displayHolder()
    })
  }

  updateInput(value) {
    this.$input.val(value.join('..'))
  }

  initJcfInputs() {
    if (this.$jcfInstance.values[1] === '0.0') {
      this.$jcfInstance.values[1] = this.$jcfInstance.maxValue
      this.$jcfInstance.refresh()
      this.initInputs()
    }
  }

  initInputs() {
    this.updateInput(this.initializeValue)
  }

  createValueHolder() {
    this.valueHolderStructure.appendTo(this.$jcfRangeHandles)
  }

  displayHolder() {
    const valueHolderMin = this.$jcfRangeHandleMin.find('.value-holder')
    const valueHolderMax = this.$jcfRangeHandleMax.find('.value-holder')

    valueHolderMin.text(this.$jcfInstance.values[0])
    valueHolderMax.text(this.$jcfInstance.values[1])
  }

  destroy() {
    this.$jcfInput = jcf.destroyAll()
  }
}
export default class RangeSliderBuilder {
  constructor() {
    this.$sliders = $('.range-slider')
    this.sliders = []

    this.$sliders.each((index, item) => { this.sliders.push(new RangeSlider($(item))) })
  }

  destroy() {
    this.sliders.forEach(slider => slider.destroy())
  }
}
