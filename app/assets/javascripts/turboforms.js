/*
This will show the errors on a Turbolinks form by using the
form HTML rendered server-side, so we don't have to manually
insert them
*/

$(document).on('turbolinks:load', function() {
  $(document).on('ajax:error', 'form', function(e) {
    if (e.detail[2].status !== 422) { return }

    for(i = 0; i < document.forms.length; i++) {
      document.forms[i].innerHTML = e.detail[0].forms[i].innerHTML
    }

    Turbolinks.dispatch('turbolinks:load')
  })
})
