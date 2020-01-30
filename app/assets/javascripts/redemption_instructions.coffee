$(document).on 'turbolinks:load', ->
  NEW_REDEMPTION_INSTRUCTION_VALUE = '0'
  PRODUCT_CATEGORY_ID = '0'
  ATTRIBUTES_INDEX = ''

  $(document.body).delegate '[data-behavior=new-redemption-instruction]', 'change', ->
    ATTRIBUTES_INDEX = $(this).data('attributesIndex')
    PRODUCT_CATEGORY_ID = $(this).data('productCategoryId')
    if $(this).val() == ''
      $("#product-category-#{ATTRIBUTES_INDEX}-instruction-text").text('')

    selectedOption = $(this).find("option:selected")
    description = selectedOption.data('description')
    $("#product-category-#{ATTRIBUTES_INDEX}-instruction-text").text(description)
    if $(this).val() == NEW_REDEMPTION_INSTRUCTION_VALUE
      $(this).val('')
      $("#product-category-#{ATTRIBUTES_INDEX}-instruction-text").text('')
      $('#redemption_instruction_product_category_id').val(PRODUCT_CATEGORY_ID)
      $('#attributes_index').val(ATTRIBUTES_INDEX)
      showModal()

  $('#new-redemption-instruction-modal').on 'hidden.bs.modal', ->
    removeErrors()
    $(this).find('form#new-redemption-instruction-form')[0].reset()

  $('#new-redemption-instruction-modal .close').on 'click', ->
    hideModal()

  $('form#new-redemption-instruction-form').on 'ajax:success', (event) ->
    redemptionInstructionId = $(this).data('frontAnchorTag') + ATTRIBUTES_INDEX + $(this).data('backAnchorTag')
    removeErrors()
    url = $(this).data('indexUrl')
    newRedemptionInstruction = event.detail[0]['redemption_instruction']
    requestRedemptionInstructionOptions(url, redemptionInstructionId, newRedemptionInstruction)
    hideModal()

  $('form#new-redemption-instruction-form').on 'ajax:error', (xhr) ->
    errors = xhr.detail[0].errors
    if errors
      for key of errors
        obj = errors[key]
        showError(key, obj[0])

  requestRedemptionInstructionOptions = (url, redemptionInstructionId, newRedemptionInstruction) ->
    request = $.ajax
      url: url
      dataType: 'json'
      type: 'GET'
      data:
        product_category_id: PRODUCT_CATEGORY_ID

      success: (data) ->
        output = ''
        $(redemptionInstructionId).empty().append ->
          data.forEach (item) ->
            output += "<option data-description='#{item.description}' value='#{item.id}'>#{item.title}</option>"
          output
        $(redemptionInstructionId).append("<option value='0'>Add New Redemption Instruction</option>")
        $(redemptionInstructionId).val(newRedemptionInstruction.id)
        $("#product-category-#{ATTRIBUTES_INDEX}-instruction-text").text(newRedemptionInstruction.description)


  showError = (key, object) ->
    $("#redemption_instruction_#{key}").addClass('invalid-input-error')
    idKey = key.replace('_', '-')
    item = key.replace('_', ' ')
    capitalItem = item.charAt(0).toUpperCase() + item.slice(1)
    error = capitalItem + ' ' + object
    $("##{idKey}-error").addClass('has-error').html(error)

  removeErrors = ->
    $('.invalid-input-error').removeClass('invalid-input-error')
    $('.has-error').html('').removeClass('has-error')

  resetModal = ->
    $('#redemption_instruction_title').val('')
    $('#redemption_instruction_description').val('')

  hideModal = ->
    resetModal()
    $('#new-redemption-instruction-modal').removeClass 'in'
    $('.modal-backdrop').remove()
    $('body').removeClass 'modal-open'
    $('#new-redemption-instruction-modal').hide()

  showModal = ->
    $('#new-redemption-instruction-modal').addClass 'in'
    $('.modal-backdrop').add()
    $('body').addClass 'modal-open'
    $('#new-redemption-instruction-modal').show()
    $('#new-redemption-instruction-modal').modal('show')
