<template>
  <div>
    <div class="container">
      <section class="enrollment-section pt-0">
        <div class="section-name">
        </div>
        <div class="section-content">
          <csv-dropzone ref="dropzone" />
          <csv-member-import-problems />
          <csv-member-table/>
        </div>
      </section>
    </div>

    <section class="enrollment-footer">
      <div class="container">
        <div class="enrollment-section">
          <div class="section-name">
          </div>
          <div class="section-content">
            <div v-if="isUploading()">
              <button disabled class="btn btn-primary">Uploading...</button>
            </div>

            <div v-else-if="canUpload()">
              <a href="javascript:;" @click="upload()" class="btn btn-primary">Upload Members</a>
            </div>

            <div class="enrollment-footer-actions" v-else>
              <slot></slot>
            </div>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
import CsvMemberImportProblems from './member-import-problems'
import CsvDropzone from './dropzone'
import CsvMemberTable from './member-table'
import Store from './store'

export default {
  props: ['formAction'],
  data: function() {
    return Store.state
  },
  methods: {
    upload: function() {
      this.$refs.dropzone.upload(this.formAction)
    },
    canUpload: function() {
      return this.members.length > 0 && !this.isUploadComplete()
    },
    isUploading: function() {
      return this.uploadStatus == 'in-progress' || this.uploadIsErrorFree()
    },
    isUploadComplete: function() {
      return this.uploadStatus == 'success'
    },
    uploadIsErrorFree: function() {
      return this.isUploadComplete() && !this.problemsProcessed
    }
  },
  components: {
    CsvDropzone,
    CsvMemberTable,
    CsvMemberImportProblems
  }
}
</script>
