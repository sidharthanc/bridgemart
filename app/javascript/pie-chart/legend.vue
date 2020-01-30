<template>
  <ul class="list-group legend">
    <li v-for="category in categories" class="list-group-item legend-item">
      <div class="legend-item-content">
        <div class="legend-item-value">
          {{ category.amount_formatted }}
        </div>
        <small class="legend-item-text">
          {{ category.name }}
        </small>
      </div>
      <div class="legend-item-color">
        <svg width="8" height="8">
          <ellipse cx="4" cy="4" rx="4" ry="4" v-bind:fill="fillColor(category.name)"></ellipse>
        </svg>
      </div>
    </li>
  </ul>
</template>

<script>
import * as d3 from 'd3'
import ColorScheme from './color-scheme'

export default {
  name: 'pie-chart-legend',
  props: {
    categories: { default: () => [] },
    colors: { default: () => ColorScheme.colors() }
  },
  created() {
    this.fetchColor = d3.scaleOrdinal().range(this.colors)
  },
  methods: {
    fillColor(key) {
      if(key == 'Remaining') {
        return '#b1bcbc'
      }
      return this.fetchColor(key)
    }
  }
}
</script>

<style scoped lang="scss">
li {
  border: none;
  padding: 16px 0 0 0;
  display: flex;
  text-align: right;
  justify-content: flex-end;

  &:first-child {
    padding: 0;
  }
}

.legend-item-color {
  margin-left: 16px;
}
</style>
