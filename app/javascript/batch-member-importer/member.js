import CsvTemplate from '../csv-template'

export default class {
  constructor(data) {
    this.firstName = data[0][CsvTemplate.FIRST_NAME]
    this.middleName = data[0][CsvTemplate.MIDDLE_NAME]
    this.lastName = data[0][CsvTemplate.LAST_NAME]
    this.email = data[0][CsvTemplate.EMAIL]
    this.externalMemberId = data[0][CsvTemplate.EXTERNAL_MEMBER_ID]

    this.street = data[0][CsvTemplate.STREET]
    this.city = data[0][CsvTemplate.CITY]
    this.state = data[0][CsvTemplate.STATE]
    this.zip = data[0][CsvTemplate.ZIP]
  }

  get address() {
    return [this.street, this.city, this.state, this.zip].join(', ')
  }

  isValid() {
    return this.firstName 
  }
}
