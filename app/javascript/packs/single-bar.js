/* eslint no-console: 0 */
import 'babel-polyfill'

import Vue from 'vue'
import SingleBar from '../single-bar/chart.vue'

document.addEventListener('turbolinks:load', () => {
  const components = [SingleBar]
  components.forEach(component => {
    const elements = Array.from(document.getElementsByTagName(component.name))
    const apps = elements.map(element => {
      return new Vue({ el: element, components: { [component.name]: component } })
    })
  })
})
