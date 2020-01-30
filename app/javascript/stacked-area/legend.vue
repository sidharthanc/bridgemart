<template>
  <ul class="stacked-area-legend">
    <li v-for="usage_type in usage_types">
      <span>
        <small>
          {{ usage_type }}
        </small>
      </span>
      <span class="color">
        <svg width="8" height="8">
          <ellipse cx="4" cy="4" rx="4" ry="4" v-bind:fill="fillColor(usage_type)"></ellipse>
        </svg>
      </span>
    </li>
  </ul>
</template>

<script>
import * as d3 from 'd3'
import ColorScheme from './color-scheme'

export default {
  name: 'stacked-area-legend',
  props: {
    categories: { default: () => [] },
    colors: { default: () => ColorScheme.colors() },
    usage_types: { default: () => [] }
  },
  created() {
    this.fetchColor = d3.scaleOrdinal().range(this.colors)
  },
  methods: {
    fillColor(key) {
      return this.fetchColor(key)
    }
  }
}
</script>

<style scoped lang="scss">
li {
  border: none;
  display: inline;
  text-align: right;
  margin-left: 10px;
}

.color {
  margin-left: 16px;
}
</style>
