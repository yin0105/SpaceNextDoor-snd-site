/**
 * Search
 */

import _ from 'lodash'

import Regions from './regions'

// Remove Empty and Duplicated regions
function removeEmptyAndDuplicate(items) {
  return _.uniq(_.compact(items))
}

class RegionSearch {
  constructor(el) {
    this.$el = $(el)
    this.data = removeEmptyAndDuplicate(Regions.flatten())
    this.placeholder = this.$el.attr('placeholder') || 'Country'

    this.$el.select2({
      width: '100%',
      placeholder: this.placeholder,
      data: this.data,
      minimumResultsForSearch: 0
    })

    this.patchSelect2()
  }

  patchSelect2() {
    this.$el.on('keydown', (e) => {
      const $select2 = this.$el.data('select2')
      const { $container } = $select2

      // Unprintable keys
      if (typeof e.which === 'undefined' || $.inArray(e.which, [0, 8, 9, 12, 16, 17, 18, 19, 20, 27, 33, 34, 35, 36, 37, 38, 39, 44, 45, 46, 91, 92, 93, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 123, 124, 144, 145, 224, 225, 57392, 63289]) >= 0) {
        return true
      }

      // Opened dropdown
      if ($container.hasClass('select2-container--open')) {
        return true
      }

      this.$el.select2('open')

      // Default search value
      const $search = $select2.dropdown.$search || $select2.selection.$search
      const query = $.inArray(e.which, [13, 40, 108]) < 0 ? String.fromCharCode(e.which) : ''
      if (query !== '') {
        $search.val(query).trigger('keyup')
      }
      return true
    })


    this.$el.on('select2:open', () => {
      const $select2 = this.$el.data('select2')
      const $dropdown = $select2.dropdown.$dropdown || $select2.selection.$dropdown
      const $search = $select2.dropdown.$search || $select2.selection.$search
      const data = this.$el.select2('data')

      // Above dropdown
      if ($dropdown.hasClass('select2-dropdown--above')) {
        $dropdown.append($search.parents('.select2-search--dropdown').detach())
      }

      // Placeholder
      let { placeholder } = this
      if (data[0] && data[0].text !== '') {
        placeholder = data[0].text
      }
      $search.attr('placeholder', placeholder)
    })

    // Auto Submit when an option being selected
    this.$el.on('select2:select', () => {
      this.$el.parents('form').submit()
    })
  }
}

export default class Search {
  constructor() {
    this.regionSearchs = []
    this.setupRegionSearch()
  }

  setupRegionSearch() {
    $('input[data-search=region]').each((v, item) => {
      this.regionSearchs.push(new RegionSearch(item))
    })
  }
}
