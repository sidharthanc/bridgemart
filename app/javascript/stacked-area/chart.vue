<template>
  <div class="chart-container">
    <svg :viewBox="viewBox">
      <g class="transactions-chart"></g>
    </svg>
  </div>
</template>

<script>
import * as d3 from 'd3'
import ColorScheme from './color-scheme'

export default {
  name: 'stacked-area',
  props: {
    usages: { default: () => {} },
    colors: { default: () => ColorScheme.colors() },
    width: { default: 850 },
    height: { default: 250 }
  },
  mounted() {
    var parseDate = d3.timeParse("%x");

    var x = d3.scaleTime().range([0, this.width]),
        y = d3.scaleLinear().range([this.height, 0]),
        z = d3.scaleOrdinal(this.colors);

    var stack = d3.stack();

    var area = d3.area()
        .x(function(d, i) { return x(parseDate(d.data.date)); })
        .y0(function(d) { return y(d[0]); })
        .y1(function(d) { return y(d[1]); });

    var g = d3.select(".transactions-chart");

    var data = this.usages,
        keys = Object.keys(data[0]).slice(1);

    x.domain(d3.extent(data, function(d) { return parseDate(d.date) }));
    y.domain([0, 500]);
    z.domain(keys);
    stack.keys(keys);

    var layer = g.selectAll(".layer")
        .data(stack(data))
        .enter().append("g")
          .attr("class", "layer");

    layer.append("path")
        .attr("class", "area")
        .style("fill", function(d) { return z(d.key); })
        .attr("d", area);

    var xAxis = d3.axisBottom(x)
        .ticks(d3.timeMonth)
        .tickSize(this.width)
        .tickFormat(d3.timeFormat("%B"));

    var xGrid = d3.axisBottom(x)
        .ticks(14)
        .tickSize(-this.width)
        .tickFormat("");

    var yAxis = d3.axisLeft(y)
        .ticks(4)
        .tickSize(0)
        .tickFormat(d3.format("$"));

    g.append("g")
        .attr("class", "grid")
        .attr("transform", "translate(0," + this.height + ")")
        .call(xGrid)
      .selectAll(".tick line")
        .style("stroke", "#929aa8")

    g.append("g")
        .attr("class", "axis x-axis")
        .call(xAxis)
      .selectAll(".tick text")
        .style("text-anchor", "start")
        .style("font", "14px sans-serif")
        .style("font-weight", "bold")
        .style("opacity", 0.5)
        .attr("x", 6)
        .attr("y", 6);

    g.select(".grid .tick")
        .style("display", "none");

    g.selectAll(".domain")
        .style("display", "none");

    g.append("g")
        .attr("class", "axis y-axis")
        .attr("transform", "translate(" + this.width + ",0)")
        .call(yAxis)
      .selectAll(".tick text")
        .style("font", "14px sans-serif")
        .style("font-weight", "bold")
        .style("opacity", .5)
        .attr("x", -12);

    g.selectAll(".y-axis .tick")
      .filter(function(d, i, list) {
        return i === list.length - 1 || i === 0;
      })
      .style("display", "none");
  },
  computed: {
    viewBox() {
      return `0 0 ${this.width} ${this.height}`
    }
  }
}
</script>

<style scoped type="scss">
  svg {
    width: 100%;
    background-color: lightgray;
    opacity: .7;
  }

  .chart-container {
    this.width: 100%;
  }
</style>
