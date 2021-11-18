// Popup Map

export default class PopupMap {
  constructor() {
    this.$map = document.querySelector('#popup-map')
    this.$popup = $('#map-modal')
    this.$links = $('[data-location]')
    this.latitude = 0
    this.longitude = 0

    this.setupLocationLink()
  }

  setupLocationLink() {
    this.$links.click((e) => {
      e.preventDefault()

      this.latitude = parseFloat(e.target.dataset.latitude) || 0
      this.longitude = parseFloat(e.target.dataset.longitude) || 0

      this.$popup.modal()
    })

    this.$popup.on('shown.bs.modal', () => { this.openMap() })
  }

  openMap() {
    if (!this.map) {
      this.initMap()
      this.initMarker()
    }

    this.map.panTo(this.currentActiveLatLng())
    this.marker.setPosition(this.currentActiveLatLng())
  }

  initMap() {
    this.map = new google.maps.Map(this.$map, {
      center: this.currentActiveLatLng(),
      zoom: 17
    })
  }

  initMarker() {
    this.marker = new google.maps.Marker({
      map: this.map,
      position: this.currentActiveLatLng()
    })
  }

  currentActiveLatLng() {
    return { lat: this.latitude, lng: this.longitude }
  }
}
