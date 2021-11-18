/**
 * Regions
 */

import _ from 'lodash'

export default class Regions {
  static flatten() {
    const extract = (item) => {
      const children = item.areas || item.cities
      return [item.name, _.flatMapDeep(children, extract)]
    }
    return _.flatMapDeep(GlobalConfig.Regions, extract)
  }
}
