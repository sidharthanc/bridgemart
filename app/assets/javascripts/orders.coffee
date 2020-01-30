$(document).on 'turbolinks:load', ->
  $('tr[data-link]').on 'click', ->
    window.location = $(this).data('link')
