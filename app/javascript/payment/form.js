import 'babel-polyfill'

import Vue from 'vue'
import ModalTemplate from '../modal-template/template.vue'

export default {
  el: '#payment-form',
  components: {
    [ModalTemplate.name]: ModalTemplate,
  },
  data: {
    achAccountName: null,
    achAccountType: null,
    achToken: null,
    bridgeTerms: false,
    address1: null,
    city: null,
    state: null,
    zip: null,
    poNumber: null,
    Notes:null,
    ccToken: null,
    ccExp: null,
    cvv: null,
    paymentType: 'credit',
    appliedCredit: 0,
    creditAmount: null,
    billing_address: true
  },
  created: function(){
    var organization_address = $('#organization-address').data('address');
    if(organization_address){
      this.address1 = organization_address.street1;
      this.city = organization_address.city;
      this.state = organization_address.state;
      this.zip = organization_address.zip;
    }
  },
  mounted() {
    this.$nextTick(function() {
      window.addEventListener('message', this.handleTokenizingResponse);
    });
  },
  beforeDestroy() {
    window.removeEventListener('message', this.handleTokenizingResponse);
  },
  computed: {
    disableForm() {
      const termsFieldExists = document.querySelector('input#payment_terms_and_conditions');
      const baseDataInvalid = (!this.bridgeTerms && termsFieldExists) ||
                              !this.address1 ||
                              !this.city ||
                              !this.state ||
                              !(/(^\d{5}$)|(^\d{5}-\d{4}$)/).test(this.zip);
      const achDataInvalid = !this.achAccountName ||
                             !this.achToken ||
                             !this.achAccountType;

      const ccDataInvalid = !this.ccToken ||
                            !this.ccExp ||
                            !this.cvv;

      if (this.creditsCoverTotalCost() && ((termsFieldExists && this.bridgeTerms) || !termsFieldExists)) return false;

      if (this.paymentType == 'credit') {
        return baseDataInvalid || ccDataInvalid;
      }

      return baseDataInvalid || achDataInvalid;
    },
    payingWithCredit() {
      return this.paymentType == 'credit';
    },
    payingWithACH() {
      return this.paymentType == 'ach';
    }
  },
  methods: {
    unableToAddCredit: function () {
      var totalCost = $('#order-total').data('amount');
      var credit_disabled = this.availableCredits() - this.creditAmount < 0 ||
                   this.creditAmount + this.appliedCredit > totalCost ||
                   this.creditAmount > totalCost ||
                   !this.creditAmount;

      if (credit_disabled) return true;

      return this.creditAmount == null || Number(this.creditAmount) < 0 || isNaN(this.creditAmount);
    },
    addCredit: function () {
      if (this.unableToAddCredit()) return true;
      this.appliedCredit += this.creditAmount;
      this.creditAmount = null;
    },
    deleteCredit: function (index) {
      this.appliedCredit = 0;
    },
    availableCredits() {
      var currentCredits = $("#total-credits").data('creditsAvailable');
      return (currentCredits - this.appliedCredit);
    },
    creditsCoverTotalCost() {
      var totalCost = $('#order-total').data('amount');
      return (this.appliedCredit >= totalCost);
    },
    setNewPaymentMethod(newMethod) {
      const hiddenField = document.getElementById('payment_payment_type');
      hiddenField.value = newMethod;
      this.paymentType = newMethod;
    },
    selectCreditCard() {
      this.setNewPaymentMethod('credit');
      this.billing_address = true
    },
    selectACHAccount() {
      this.setNewPaymentMethod('ach');
      this.billing_address = true
    },
    selectCredits() {
      this.billing_address = false
    },
    submit(e) {
      if (this.creditsCoverTotalCost()) this.setNewPaymentMethod('accrued_credits');

      const form = $(this.$el);
      form.submit();
    },
    handleTokenizingResponse: function(event) {
      // Next line doesn't allow us to stub this message out in the user tests
      // if (event.origin !== "https://fts.cardconnect.com") return;
      try {
          var payload = JSON.parse(event.data);
          if (payload.hasOwnProperty('ccToken')) {
            console.log('Received Token (cc)');
            this.ccToken = payload.ccToken;
            document.getElementById('credit_card_token').value = this.ccToken;
          } else if (payload.hasOwnProperty('achToken')) {
            console.log('Received Token (ach)');
            this.achToken = payload.achToken;
            document.getElementById('ach_token').value = this.achToken;
          }
      } catch (e) {
          return false;
      }
    }
  }
}
