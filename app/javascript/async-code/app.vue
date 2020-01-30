<template>
  <div>
    <div class="frame-wrapper" v-if="cardImageUrl == null && barcodeUrl == null">
      {{ loadingText }}
    </div>

    <div class="frame-wrapper" v-if="cardImageUrl">
      <iframe id="card-iframe" class="card-iframe" :src="cardImageUrl"></iframe>
    </div>
    <div class="frame-wrapper frame-wrapper--white" v-if="barcodeUrl">
      <iframe id="barcode-iframe" class="barcode-iframe" :src="barcodeUrl"></iframe>
    </div>
  </div>
</template>

<script>
export default {
  el: '#async-code',
  data: function() {
    return {
      asyncUrl: null,
      loadingText: null,
      pollInterval: 3000,
      barcodeUrl: null,
      cardImageUrl: null
    }
  },

  beforeMount: function() {
    this.asyncUrl = this.$el.attributes['async-url'].value
    this.loadingText = this.$el.attributes['loading-text'].value
  },

  mounted: function() {
    this.interval = setInterval(() => { this.poll() }, this.pollInterval)
  },

  beforeDestroy: function() {
    this.stopPolling()
  },

  methods: {
    poll() {
      if (this.barcodeUrl != null && this.cardImageUrl != null) {
        this.stopPolling()
        return
      }

      $.getJSON(this.asyncUrl, { dataType: 'json' }, (response) => {
        this.barcodeUrl = response.barcode_url
        this.cardImageUrl = response.card_image_url
      })
    },

    stopPolling() {
      clearInterval(this.interval)
    }
  }
}
</script>
