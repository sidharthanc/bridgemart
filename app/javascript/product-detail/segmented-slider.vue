<template>
  <span>
    <template v-if="inputValue >= lowestPrice">
      <div>Each member can afford a <b>{{ lowerBoundItem }}</b>.</div>
      <div><i>{{ upgradeVerbiage }}</i></div>
    </template>
    <template v-if="inputValue < lowestPrice">
      <div>Each member will be <b>${{ this.minimumDifference }} short </b> of a {{ this.upgradeItem }}.</div>
      <div><i>{{ mimimumUpgradeVerbiage() }}</i></div>
    </template>
  </span>
</template>

<script>
export default {
  props: ['pricePoints', 'inputValue', 'sliderMinimum'],
  data: function () {
    return {
      cardTextClass: 'card-text'
    }
  },
  computed: {
    lowestPrice: function() {
      return this.sortedPricePoints[0].limit
    },
    sortedPricePoints: function() {
      return this.pricePoints.sort((left, right) => left.limit - right.limit)
    },
    lowerBoundItem: function () {
      var input = this.inputValue
      var min = this.sliderMinimum
      var lowerLimit = ''
      this.pricePoints.forEach(function (pricePoint) {
        if (input >= pricePoint.limit) {
          lowerLimit = pricePoint.item_name
        }
      })
      return lowerLimit
    },
    upgradeVerbiage: function () {
      var input = this.inputValue
      var msg = ''
      this.pricePoints.forEach(function (pricePoint) {
        if (pricePoint.limit == input) {
          msg = pricePoint.upgrade_verbiage
        }
      })
      return msg
    },
    minimumDifference: function () {
      var val = 0
      if (this.inputValue >= this.pricePoints[0].limit) {
        val = this.sliderMinimum - this.inputValue
      } else {
        val = this.pricePoints[0].limit - this.inputValue
      }
      var formattedNumber = (val).toFixed(2).replace(/[.,]00$/, "")
      return formattedNumber
    },
    upgradeItem: function () {
      if (this.inputValue >= this.pricePoints[0].limit) {
        return this.pricePoints[1].item_name
      } else {
        return this.pricePoints[0].item_name
      }
    }
  },
  methods: {
    mimimumUpgradeVerbiage: function () {
      var diff = this.minimumDifference
      var item = this.sortedPricePoints[0].item_name
      return `$${diff} more to upgrade to a ${item}.`
    }
  }
}
</script>

<style>
</style>