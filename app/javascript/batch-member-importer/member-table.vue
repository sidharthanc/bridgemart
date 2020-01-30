<template>

  <div class="member-container" v-if="errorFreeUpload()">
    <header>
      <div spacer></div>
      <span class="header-message" v-if="membersEquivalentToRows()"> All members can be uploaded successfully</span>
      <span class="header-message" v-else> Only {{ members.length }} out of {{ rows.length - 1 }} member(s) can be uploaded successfully </span>
      <a href="javascript:;" @click="reset()" class="close-btn">&times;</a>
    </header>
    <div class="member-table">
      <div class="tr header">
        <div class="cell">First Name</div>
        <div class="cell">Middle Name</div>
        <div class="cell">Last Name</div>
        <div class="cell">Email</div>
        <div class="cell">Address</div>
        <div class="cell">External Member Id</div>
      </div>
      <div class="tr" v-for="member in members.slice(0, 5)">
        <div class="cell">{{ member.firstName }}</div>
        <div class="cell">{{ member.middleName }}</div>
        <div class="cell">{{ member.lastName }}</div>
        <div class="cell">{{ member.email }}</div>
        <div class="cell">{{ member.address }}</div>
        <div class="cell">{{ member.externalMemberId }}</div>
      </div>
      <footer v-if="members.length > 5">
        Plus {{ members.length - 5 }} more rows
      </footer>
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
    },
    errorFreeUpload: function() {
      return this.members.length > 0 && this.problems == null
    },
    membersEquivalentToRows: function() {
      return this.members.length == this.rows.length - 1
    }
  }
}
</script>

<style scoped lang="scss">
  @import "../../assets/stylesheets/colors.scss";
  @import "../../assets/stylesheets/variables.scss";

  $close-btn-size: 34px;
  $cell-width: 105px;
  $cell-font-size: .85em;

  .member-container {
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

  footer {
    font-style: italic;
    font-size: $cell-font-size;
    color: $gray-font-color;
    text-align: center;
    width: 100%;
  }

  .header-message {
    flex: 1;
    text-align: center;
  }

  a.close-btn {
    height: $close-btn-size;
    width: $close-btn-size;
    font-size: 2em;
    display: block;
    color: $primary-color;
    background-color: $dark-gray;
    text-align: center;
    line-height: $close-btn-size;
    border-radius: $border-radius;

    &:hover {
      text-decoration: none;
    }
  }

  .member-table {
    background-color: $dark-gray;
    padding-bottom: $cell-font-size;
  }

  .tr {
    width: 100vw;
    display: flex;
    padding: 0 1rem;

    &.header {
      color: $gray-font-color;
      text-transform: uppercase;
      font-size: .8em;
      font-weight: bold;
      border-bottom: 1px solid lighten($gray-font-color, 20%);
    }

    .cell {
      padding: .5rem;
      padding-left: 0;
      font-size: $cell-font-size;
      width: $cell-width;
      overflow-x: hidden;
      white-space: nowrap;
      text-overflow: ellipsis;
    }
  }
</style>
