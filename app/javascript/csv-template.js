export default class {
  static FIRST_NAME = 'FirstName'
  static MIDDLE_NAME = 'MiddleName'
  static LAST_NAME = 'LastName'
  static EMAIL = 'Email'
  static STREET = 'Street'
  static CITY = 'City'
  static STATE = 'State'
  static ZIP = 'Zip'
  static EXTERNAL_MEMBER_ID = 'ExternalMemberId'

  static getHeaders() {
    return [
      this.FIRST_NAME,
      this.MIDDLE_NAME,
      this.LAST_NAME,
      this.EMAIL,
      this.STREET,
      this.CITY,
      this.STATE,
      this.ZIP,
      this.EXTERNAL_MEMBER_ID
    ].join(',')
  }
}
