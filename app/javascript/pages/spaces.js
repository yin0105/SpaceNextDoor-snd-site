import _ from 'lodash'

export class SpacesPage {
  constructor() {
    this.$spaces = $('#space-index')
    this.$searchForm = this.$spaces.find('[data-search-trigger]')
    this.$searchForm.submit(this.readUserLocation)
    this.setupSearchTrigger()
  }

  setupSearchTrigger() {
    const submit = () => {
      this.$searchForm.submit()
    }
    this.$searchForm.find('input,select').change(submit)
  }
}

export class SpacePage {
  constructor() {
    this.$slides = $('#space .rslides')
    this.$sidebar = $('#space .space__sidebar')
    this.$sidebarToggle = $('.space__sidebar-toggle')
    this.$sidebarTarget = $('#space-sidebar-toggle')

    this.setupSidebarToggle()
    this.setupSlideshow()
  }

  setupSidebarToggle() {
    this.$sidebarToggle.on('click', (e) => {
      e.preventDefault()
      this.$sidebar.find('.space__sidebar-toggle').toggleClass('collapsed')
      this.$sidebarTarget.toggleClass('space__booking-details__block')
      this.$sidebarTarget.toggleClass('collapse')
    })
  }

  setupSlideshow() {
    this.$slides.responsiveSlides({
      nav: true,
      pager: true,
      prevText: "<i class='fa fa-caret-left text-white'></i>",
      nextText: "<i class='fa fa-caret-right text-white'></i>"
    })
  }
}

export class SpacesMap {
  constructor(el) {
    this.$map = $(el)
    if (this.$map.length <= 0) return
    this.initMap()
    this.updateMarkers()
    this.setMapToShowAllMarkers()
  }

  initMap() {
    this.map = new google.maps.Map(this.$map[0], {
      maxZoom: 18
      // map settings
    })
  }

  deactiveAllMarkers() {
    _.forEach(this.markers, (marker) => {
      marker.setIcon(
        marker.status
          ? GlobalConfig.Assets.Map.Available
          : GlobalConfig.Assets.Map.Booked,
      )
      marker.setZIndex(1)
    })
  }

  updateMarkers() {
    if (this.markers) _.forEach(this.markers, marker => marker.setMap(null))
    let spaces = this.constructor.getSpaceDataFromPage()
    spaces = spaces.filter(space => space.latitude && space.longitude)
    this.markers = spaces.map((space) => {
      const latlng = new google.maps.LatLng(space.latitude, space.longitude)
      const marker = new google.maps.Marker({
        position: latlng,
        title: space.name,
        status: space.status,
        icon: space.status
          ? GlobalConfig.Assets.Map.Available
          : GlobalConfig.Assets.Map.Booked
      })
      marker.addListener('click', () => { document.location.href = space.path })
      marker.setMap(this.map)
      space.$el.hover(
        () => {
          marker.setIcon(GlobalConfig.Assets.Map.Active)
          marker.setZIndex(google.maps.Marker.MAX_ZINDEX + 1)
        },
        () => { this.deactiveAllMarkers() },
      )
      return marker
    })
  }

  setMapToShowAllMarkers() {
    const bounds = new google.maps.LatLngBounds()

    if (this.markers && this.markers.length > 0) {
      _.forEach(this.markers, (marker) => {
        bounds.extend(marker.position)
      })
    } else {
      bounds.extend({ lat: 60, lng: 120 })
      bounds.extend({ lat: -60, lng: -120 })
    }

    this.map.fitBounds(bounds)
  }

  static getSpaceDataFromPage() {
    return $('[data-space-id]').map((_i, spaceElement) => {
      const $spaceElement = $(spaceElement)

      return {
        id: $spaceElement.data('space-id'),
        name: $spaceElement.data('space-name'),
        latitude: $spaceElement.data('space-latitude'),
        longitude: $spaceElement.data('space-longitude'),
        status: $spaceElement.data('space-status'),
        path: $spaceElement.data('space-path'),
        $el: $spaceElement
      }
    }).toArray()
  }
}

export default SpacesPage
