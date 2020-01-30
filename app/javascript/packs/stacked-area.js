/* eslint no-console: 0 */
import 'babel-polyfill'

import Vue from 'vue'
import StackedArea from '../stacked-area/chart.vue'
import StackedAreaLegend from '../stacked-area/legend.vue'


document.addEventListener('turbolinks:load', () => {
  const components = [StackedArea, StackedAreaLegend]
  components.forEach(component => {
    const elements = Array.from(document.getElementsByTagName(component.name))
    const apps = elements.map(element => {
      return new Vue({ el: element, components: { [component.name]: component } })
    })
  })
})
