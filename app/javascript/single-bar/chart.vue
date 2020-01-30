<template>
  <div class="chart-container">
    <svg :viewBox="viewBox">
      <g :transform="transform">
        <rect :y="0" :x="0" :height="height" :width="widthVal(usage)" :fill="colors[0]">
        </rect>
        <rect :y="0" :x="widthVal(usage)" :height="height" :width="widthVal(1 - usage)" :fill="colors[1]">
        </rect>
      </g>
    </svg>
  </div>
</template>

<script>
import * as d3 from 'd3'

export default {
  name: 'single-bar',
  props: {
    usage: { default: 0 },
    colors: { default: () => ['#70F2F2', '#b1bcbc'] },
    width: { default: 500 },
    height: { default: 35 }
  },
  computed: {
    transform() {
      return `translate(0,0)`
    },
    viewBox() {
      return `0 0 ${this.width} ${this.height}`
    }
  },
  methods: {
    widthVal(percent) {
      var xScale = d3.scaleLinear().domain([0, 1]).range([0, this.width])
      return xScale(percent)
    }
  }
}
</script>

<style scoped type="scss">
  svg {
    height: 35px;
    width: 100%
  }

  .chart-container {
    width: 100%;
  }
</style>
