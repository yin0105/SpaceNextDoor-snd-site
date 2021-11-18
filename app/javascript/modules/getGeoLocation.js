function saveLocation(position) {
  localStorage.setItem('latitude', position.coords.latitude)
  localStorage.setItem('longitude', position.coords.longitude)
}

function updateSearch() {
  const latitudeField = document.getElementById('search_user_latitude')
  const longitudeField = document.getElementById('search_user_longitude')
  if (!!latitudeField || !!longitudeField) {
    latitudeField.value = localStorage.getItem('latitude')
    longitudeField.value = localStorage.getItem('longitude')
  }
}
const getGeoLocation = () => {
  if ('geolocation' in navigator) {
    navigator.geolocation.getCurrentPosition(saveLocation)
  }
  updateSearch()
}

export default getGeoLocation
