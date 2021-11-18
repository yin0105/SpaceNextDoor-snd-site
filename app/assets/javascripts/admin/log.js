import JsonViewer from 'json-viewer-js'

$(document).ready(() => {
  $('.version-changes').each((_index, element) => {
    const data = $(element).data('info')
    // eslint-disable-next-line
    Object.keys(data).map((k) => {
      data[k] = { old: data[k][0], new: data[k][1] }
    })
    // eslint-disable-next-line
    new JsonViewer({
      container: element,
      data: JSON.stringify(data),
      theme: 'light',
      expand: true
    })
  })
})
