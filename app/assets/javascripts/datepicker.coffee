$(document).on 'ready page:load', ->
  $('[data-provide="datepicker"]').datepicker
    viewMode: 'years'
    clearBtn: true
    format: 'mm/dd/yyyy'
    autoclose: true
    startDate: '-0d'

  $('[data-provide="dob"]').datepicker
    viewMode: 'years'
    format: 'mm/dd/yyyy'
    autoclose: true
    endDate: '-1d'

$(document).on 'turbolinks:load', ->
  $('.datepicker').datepicker
    viewMode: 'years'
    format: 'mm/dd/yyyy'
    autoclose: true
