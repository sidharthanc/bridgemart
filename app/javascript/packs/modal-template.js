import 'babel-polyfill'

import Vue from 'vue'
import ModalTemplate from '../modal-template/template.vue'

document.addEventListener('turbolinks:load', () => {
  const components = [ModalTemplate]
  components.forEach(component => {
    const elements = Array.from(document.getElementsByTagName(component.name))
    const apps = elements.map(element => {
      return new Vue({ el: element, components: { [component.name]: component } })
    })
  })
})

