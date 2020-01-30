<template>
  <div>
    <span class="checkbox">
      <slot name="checkbox"></slot>
    </span>
    <span @click="showModal()" class="click-text">
      <slot name="modal-text"></slot>
    </span>
    <b-modal v-model="show" id="myModal" size="lg">
      <div slot="modal-title" class="title">
        <slot name="title-text"></slot>
      </div>
      <slot name="body"></slot>
      <div slot="modal-footer" class="w-100">
        <b-btn size="sm" class="float-right" variant="primary" @click="hideModal(); enableElement(); checkElement();">
          <slot name="button-text"></slot>
        </b-btn>
      </div>
    </b-modal>
  </div>
</template>

<script>
import Vue from 'vue'
import BootstrapVue from 'bootstrap-vue'

Vue.use(BootstrapVue)

export default {
  props: ['disabledElement'],
  name: 'modal-template',
  data () {
    return {
      show: false,
      variants: [
        'primary'
      ]
    }
  },
  methods: {
    showModal: function () {
      return this.show = true
    },
    hideModal: function () {
      return this.show = false
    },
    enableElement: function () {
      if (this.disabledElement) {
        $(this.disabledElement).prop('disabled', false);
      }
    },
    checkElement: function () {
      if (this.disabledElement) {
        if (!$(this.disabledElement).prop('checked')) {
          $(this.disabledElement).click();
        }
      }
    }
  },
  mounted: function () {
    $(this.disabledElement).prop('disabled', true);
  }
}
</script>

<style>
  .title {
    font-weight: bold;
  }

  .click-text {
    cursor: pointer;
    color: #0c9c4a;
  }

  .click-text:hover {
    text-decoration: underline;
  }
</style>