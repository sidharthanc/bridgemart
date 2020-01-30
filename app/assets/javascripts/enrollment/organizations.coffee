$(document).on 'turbolinks:load', ->
  $('.enrollment-organization-product-categories input:checkbox').addClass 'input_hidden'

  $('.enrollment-organization-product-categories input:checked').each (index, element) ->
    $(element).parent().toggleClass('selected')

  $('[data-behavior=select-images] label').on 'change', ->
    $(this).toggleClass('selected')

  $('.organization__product-category-option').tooltip({
    html: true,
    trigger: 'hover',
    delay: {
      show: 250,
      hide: 0
    },
    placement: 'right',
    template: '<div class="tooltip product-category-tooltip" role="tooltip"><div class="tooltip-inner"></div></div>'
  })
