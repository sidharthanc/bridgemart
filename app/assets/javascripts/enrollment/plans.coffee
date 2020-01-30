$(document).on 'turbolinks:load change', ->
  startDate = $('#order_starts_on').val()
  endDate = $('#order_ends_on').val()
  if endDate == ''
    endDate = moment(startDate).add(1, 'year').calendar()
    $('#order_ends_on').val(endDate)
  else
    endDate = moment(endDate).calendar()
    $('#order_ends_on').val(endDate)

  $('#decline_special_offers').on 'change', ->
    for check in $('.special-offer-check')
      check.checked=false
      check.disabled=$('#decline_special_offers')[0].checked
