import 'babel-polyfill'

import Vue from 'vue'
import ProductSliderApp from '../product-detail/app.vue'

document.addEventListener('turbolinks:load', () => {
  [ProductSliderApp].forEach(function(app) {
    if (document.getElementById(app.el.substring(1))) {
      new Vue(app)
    }
  })
})
