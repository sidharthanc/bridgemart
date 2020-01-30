/* eslint no-console: 0 */
import 'babel-polyfill'

import Vue from 'vue'
import PieChart from '../pie-chart/chart.vue'
import PieChartLegend from '../pie-chart/legend.vue'

document.addEventListener('turbolinks:load', () => {
  const components = [PieChart, PieChartLegend]
  components.forEach(component => {
    const elements = Array.from(document.getElementsByTagName(component.name))
    const apps = elements.map(element => {
      return new Vue({ el: element, components: { [component.name]: component } })
    })
  })
})
