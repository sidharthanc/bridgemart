<template>
  <div v-show="members.length == 0">
    <form action="#" ref="dropzoneForm" class="dropzone-form">
      <div data-behavior="choose-file">
        Drag a .csv file here to upload<br />or <em>browse</em> to select a file
      </div>
    </form>
  </div>
</template>

<script>
import Dropzone from 'dropzone'
import Papa from 'papaparse'
import Store from './store'
import Member from './member'

export default {
  data: function() {
    return Store.state
  },
  methods: {
    upload: function(url) {
      this.dropzone.options.url = url
      Store.uploadInProgress()
      this.dropzone.processQueue()
    },
    poll: function () {
      if (Store.state.problems == null && Store.state.memberImport != null) {
        $.getJSON(Store.pollUrl(), { dataType: 'json' }, (response) => {

        if (response.problems != null) {
          Store.state.problemsProcessed = true

          if (response.problems.length > 0) {
             Store.state.problems = response.problems
           }
           else
           {
  $('#enable_complete_billing_button').html('<a href=/enrollment/orders/'+response.order_id+'/payments/new class="btn btn-wide btn-primary ">'+
  'Complete &amp; Go To Billing</a>');
           }
          }
        })
      }
    }
  },
  mounted: function() {
    this.interval = setInterval(() => { this.poll() }, this.pollInterval)

    this.dropzone = new Dropzone(this.$refs.dropzoneForm, {
      clickable: '[data-behavior="choose-file"]',
      autoProcessQueue: false,
      previewsContainer: false,
      headers: {
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      }
    })

    this.dropzone.on('addedfile', function(file) {
      Store.setFile(file)

      Papa.parse(file, {
        header: true,
      	step: function(row) {
          let member = new Member(row.data)

          if (member.isValid()) {
            Store.addMember(member)
          }
          Store.addRow(row)
      	},
      })
    })

    this.dropzone.on('queuecomplete', function() {
      Store.uploadSuccess()
    })

    this.dropzone.on('success', function(file, xhr, progressEvent) {
      Store.setMemberImport(xhr.member_import)
    })
  },
}
</script>

<style scoped lang="scss">
  @import "../../assets/stylesheets/colors";

  em {
    color: $primary-color;
    font-style: normal;
    font-weight: bold;

    &:hover {
      cursor: pointer;
    }
  }

  .dropzone-form {
    height: 290px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background-color: $dark-gray;
  }

  *[data-behavior="choose-file"] {
    display: 1;
    text-align: center;
  }
</style>
