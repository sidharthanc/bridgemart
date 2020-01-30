<template>
  <div class="chart-container">
    <svg :width="diameter" :height="diameter">
      <g :transform="transform">
        <path
          v-for="slice in slices"
          :fill="fillColor(slice.data.name)"
          :d="arc(slice)">
        </path>
      </g>
    </svg>
  </div>
</template>

<script>
import * as d3 from 'd3'
import ColorScheme from './color-scheme'

export default {
  name: 'pie-chart',
  props: {
    categories: { default: () => [] },
    colors: { default: () => ColorScheme.colors() },
    radius: { default: 75 },
    thickness: { default: 15 }
  },
  created() {
    this.fetchColor = d3.scaleOrdinal().domain([]).range(this.colors)
  },
  computed: {
    diameter() {
      return this.radius * 2
    },
    transform() {
      return `translate(${this.radius},${this.radius})`
    },
    slices() {
      const computeSlices = d3.pie()
        .value(item => item.amount)
        .sort(null)

      return computeSlices(this.categories)
    }
  },
  methods: {
    fillColor(key) {
      return this.fetchColor(key)
    },
    arc({ startAngle, endAngle }) {
      const computeArc = d3.arc()
        .innerRadius(this.radius - this.thickness)
        .outerRadius(this.radius)

      return computeArc({ startAngle, endAngle })
    }
  }
}
</script>

<style scoped type="scss">
</style>
