import { isAllDaysAvailable } from 'pages/discount_options'

test('isAllDaysAvailable returns true if all days are available', () => {
  expect(isAllDaysAvailable('2021-02-24', ['2021-02-24', '2021-02-25', '2021-02-26'], 3)).toBe(true)
})

test('isAllDaysAvailable returns false if not all days are available', () => {
  expect(isAllDaysAvailable('2021-02-24', ['2021-02-24', '2021-02-26', '2021-02-27'], 3)).toBe(false)
})
