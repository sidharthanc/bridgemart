<template>
  <div>
    <vue-slider v-if="multiplePricePoints" ref="slider" v-model="slideValue" type="number" v-on:click.native="changeSlideAmount" v-on:drag-end="changeSlideAmount" v-bind:style="slideStyle" v-bind="options" :max="maximumLimit">
      <div slot="piecewise" slot-scope="{ label, active }" :class="[markerClass]" :id="limitType(label)" v-if="labelForLimit(label)">
        <div v-b-tooltip.hover :class="[tooltipMarkerClass]" :title="tooltipTitle(label)">
          -
        </div>
      </div>
    </vue-slider>
    <b-container>
      <b-row>
        <b-col cols="4">
          <span v-bind:style="inputPretextStyle">$</span>
          <slot v-on:keydown.enter.prevent="changeInputAmount" v-on:blur="changeInputAmount" v-bind:changeInputAmount="changeInputAmount" v-bind:inputValue="inputValue"></slot>
        </b-col>
        <b-col cols="8">
          <segmented-slider ref="segmented" :price-points="sortedPricePoints" :input-value="inputValue" :slider-minimum="options.min" v-if="multiplePricePoints">
          </segmented-slider>
        </b-col>
      </b-row>
    </b-container>
  </div>
</template>

<script>
import vueSlider from 'vue-slider-component'
import Vue from 'vue'
import BootstrapVue from 'bootstrap-vue'
import SegmentedSlider from './segmented-slider'

Vue.use(BootstrapVue)

export default {
  props: ['basicPricePoint', 'pricePoints', 'originalInput'],
  data: function () {
    return {
      options: {
        sliderStyle: {
          backgroundColor:'#0c9c4a'
        },
        processStyle: {
          backgroundColor: 'transparent'
        },
        piecewiseStyle: {
          backgroundColor: 'transparent',
          borderRadius: '0px',
          weight: '1px'
        },
        tooltipStyle: {
          color: 'transparent',
          backgroundColor: 'transparent',
          borderColor: 'transparent'
        },
        min: this.basicPricePoint,
        piecewise: true,
        show: true,
        dotSize: 20
      },
      tooltipMarkerClass: 'tooltip-marker',
      markerClass: 'marker',
      slideValue: this.originalInput,
      amount: this.originalInput,
      inputValue: this.originalInput,
      inputPretextStyle: {
        fontSize: '1.5em',
      },
      slideStyle: {
        paddingBottom: '2em'
      }
    }
  },
  computed: {
    singlePricePoint: function () {
      if (this.pricePoints.length == 1) {
        return this.pricePoints[0]
      }
    },
    multiplePricePoints: function () {
      return (this.pricePoints.length >= 2)
    },
    maximumLimit: function () {
      return this.sortedPricePoints[this.pricePoints.length - 1].limit
    },
    sortedPricePoints: function() {
      return this.pricePoints.sort((left, right) => left.limit - right.limit)
    }
  },
  methods: {
    tooltipTitle: function (label) {
        var msg = ''
      this.pricePoints.forEach(function (pricePoint) {
        if (pricePoint.limit == label) {
          msg = pricePoint.tooltip
        }
      })
      return msg
    },
    labelForLimit: function (label) {
      var showLabel = false
      this.pricePoints.forEach(function (pricePoint) {
        if (label == pricePoint.limit){
          showLabel = true
        }
      })
      return showLabel
    },
    limitType: function (label) {
      var options = this.options
      var max = this.maximumLimit
      var idTitle = ''
      this.pricePoints.forEach(function (pricePoint) {
        if (label == pricePoint.limit){
          if (label == options.min) {
            idTitle = 'basic'
          } else if (label == max) {
            idTitle = 'high-end'
          } else {
            idTitle = 'mid-range-' + label
          }
        }
      })
      return idTitle
    },
    changeInputAmount: function(e) {
      this.inputValue = this.precisionRound(e.target.value)
      this.amount = this.inputValue
      if (this.inputValue < 1) {
        this.inputValue = this.options.min
      }
      // if (this.inputValue <= this.options.min) {
      //    this.slideValue = this.inputValue = this.options.min
      // } else if (this.inputValue >= this.maximumLimit) {
      //   this.slideValue = this.inputValue = this.maximumLimit
      // } else {
      //   this.slideValue = this.inputValue
      // }
    },
    changeSlideAmount: function(e) {
      this.amount = this.slideValue
      this.inputValue = this.slideValue
    },
    precisionRound: function (number) {
      var factor = Math.pow(10, 2)
      var value = Math.round(number * factor) / factor
      var formattedNumber = (value).toFixed(2).replace(/[.,]00$/, "")
      return formattedNumber
    }
  },
  mounted: function () {
    this.$nextTick(function () {
      let startPrice = (this.singlePricePoint) ? this.singlePricePoint.limit : this.basicPricePoint
      let value = (this.originalInput > 0) ? this.originalInput : startPrice
      this.slideValue = value
      this.amount = value
      this.inputValue = value

      $('.marker').each(function(i, obj) {
        obj.parentNode.style['background-color'] = '#0c9c4a'
        if (obj.id == 'basic') {
          obj.parentNode.style['border-top-left-radius'] = '20px'
          obj.parentNode.style['border-bottom-left-radius'] = '20px'
        } else if (obj.id == 'high-end') {
          obj.parentNode.style['border-top-right-radius'] = '20px'
          obj.parentNode.style['border-bottom-right-radius'] = '20px'
        }
      })
    })
  },
  components: {
    vueSlider, SegmentedSlider
  }
}
</script>

<style scoped lang="scss">
  .tooltip-marker {
    background-color: #0c9c4a;
    width: 6px;
    height: 6px;
    margin-top: 0px;
    color: transparent;
    border-top-left-radius: 20px;
    border-bottom-left-radius: 20px;
    border-top-right-radius: 20px;
    border-bottom-right-radius: 20px;
  }

  input {
    padding-left: 5px;
  }
</style>
