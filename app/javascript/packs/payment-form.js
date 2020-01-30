/* eslint no-console: 0 */
import 'babel-polyfill'

import Vue from 'vue'
import PaymentForm from '../payment/form.js'

document.addEventListener('turbolinks:load', () => {
  new Vue(PaymentForm);
})
