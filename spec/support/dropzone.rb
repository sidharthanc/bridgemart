module Dropzone
  def drop_file(filepath)
    page.execute_script <<~JS
      jQuery('#fake-file-input').remove()
      input = $('<input/>').attr({ id: 'fake-file-input', type: 'file' }).appendTo('body');
    JS

    attach_file 'fake-file-input', filepath

    page.execute_script <<~JS
      var e = jQuery.Event('drop', { dataTransfer : { files : [input.get(0).files[0]] } });
      $('.dropzone-form')[0].dropzone.listeners[0].events.drop(e);
    JS
  end
end

RSpec.configure do |config|
  config.include Dropzone
end
