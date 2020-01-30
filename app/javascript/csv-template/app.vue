<template>
  <div>
    <div class="mt-3">
      <a href="javascript:;" @click="viewTemplate()" class="btn btn-gray mr-3">View Template</a>
      <a href="javascript:;" @click="downloadTemplate()" class="btn btn-gray">Download Template</a>
    </div>
    <code v-if="viewing" class="mt-3">
      {{ template }}
    </code>
  </div>
</template>

<script>
import CsvTemplate from '../csv-template.js'

export default {
  el: '#csv-templates',
  data: function() {
    return {
      viewing: false,
      template: CsvTemplate.getHeaders(),
    }
  },
  methods: {
    viewTemplate: function() {
      this.viewing = !this.viewing
    },
    downloadTemplate: function() {
      const filename = 'bridgemart-csv-template.csv'
      let csvData = new Blob([this.template], { type: 'text/csv;charset=utf-8;' });

      if (navigator.msSaveBlob) { // ie11, edge
        navigator.msSaveBlob(csvData, filename);
      } else {
        let link = document.createElement('a')
        link.href = window.URL.createObjectURL(csvData)
        link.setAttribute('download', filename)
        document.body.appendChild(link)
        link.click()
        document.body.removeChild(link)
      }
    }
  }
}
</script>

<style scoped lang="scss">
  @import "../../assets/stylesheets/colors";

  code {
    display: block;
    overflow-x: scroll;
    font-size: 80%;
    color: $primary-color;
    background-color: $dark-gray;
    padding: 1em;
  }
</style>
