<template>
  <div class="error-container" v-if="problems != null">
    <header>
      <div spacer></div>
      <span class="header-message">There were errors, please retry the upload.</span>
      <a href="javascript:;" @click="reset()" class="retry-btn">retry</a>
    </header>
    <div class="errors">
      <div v-for="problem in problems">
        Row {{ problem.index + 1 }}: {{ problem.errors.join(', ') }}
      </div>
    </div>
  </div>
</template>

<script>
import Store from './store'
import Member from './member'

export default {
  data: function() {
    return Store.state
  },
  methods: {
    reset: function() {
      Store.reset()
    }
  }
}
</script>

<style scoped lang="scss">
  @import "../../assets/stylesheets/colors.scss";
  @import "../../assets/stylesheets/variables.scss";

  $retry-btn-size-height: 34px;
  $retry-btn-size-width: 50px;

  .error-container {
    width: 610px;
    overflow-x: hidden;
  }

  header {
    display: flex;
    background-color: $white;
    align-items: center;
    padding: .75em;
    border-top-left-radius: $border-radius;
    border-top-right-radius: $border-radius;
  }

  .errors {
    color: $red-error-color;
  }

  .header-message {
    flex: 1;
    text-align: center;
  }

  a.retry-btn {
    height: $retry-btn-size-height;
    width: $retry-btn-size-width;
    font-size: 1em;
    display: block;
    color: $primary-color;
    background-color: $dark-gray;
    text-align: center;
    line-height: $retry-btn-size-height;
    border-radius: $border-radius;

    &:hover {
      text-decoration: none;
    }
  }
</style>
