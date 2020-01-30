/* eslint no-console: 0 */
import Vue from 'vue'
import BatchApp from '../batch-member-importer/app.vue'
import CsvTemplateApp from '../csv-template/app.vue'
import AsyncCode from '../async-code/app.vue'
import Confirmer from '../payment/confirmer.js'

document.addEventListener('turbolinks:load', () => {
  [BatchApp, CsvTemplateApp, AsyncCode, Confirmer].forEach(function(app) {
    if (document.getElementById(app.el.substring(1))) {
      new Vue(app)
    }
  })
})
