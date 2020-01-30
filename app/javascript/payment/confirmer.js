import 'babel-polyfill'

import Vue from 'vue'

export default {
  el: '#payment-confirmer',
  data: function() {
    return {
      asyncUrl: null,
      redirectUrl: null,
      pollInterval: 2000
    }
  },

  beforeMount: function() {
    this.asyncUrl = this.$el.attributes['async-url'].value;
    this.redirectUrl = this.$el.attributes['redirect-url'].value;
  },

  mounted: function() {
    this.poll();
  },

  methods: {
    poll() {
      $.getJSON(this.asyncUrl, this.response);
    },

    response(resp) {
      const order = resp;
      if (!order.processed_at) {
        setTimeout(this.poll, this.pollInterval);
        return;
      }
      window.location = this.redirectUrl;
    }
  }
}
