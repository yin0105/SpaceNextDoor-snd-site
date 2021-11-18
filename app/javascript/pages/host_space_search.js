function HostSpaceSearch() {
  const $searchForm = $('#host-space-search-filter')
  const $spaceRegion = document.getElementById('user_search_space_region')
  const $spaceSearch = $searchForm.find('#user_search_space_field')

  $spaceSearch.select2({
    width: '100%',
    placeholder: $spaceSearch.attr('placeholder'),
    minimumInputLength: 1,
    ajax: {
      url: '/users/spaces/query_spaces',
      type: 'get',
      data: params => ({
        field: params.term,
        region: $spaceRegion.value
      }),
      processResults: data => ({
        results: data
      })
    }
  })

  $spaceSearch.on('change', () => {
    $spaceSearch.parents('form').submit()
  })
}

export default HostSpaceSearch
