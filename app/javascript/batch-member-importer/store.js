export default {
  state: {
    members: [],
    uploadStatus: 'idle',
    file: null,
    memberImport: null,
    problems: null,
    pollInterval: 3000,
    rows: [],
    problemsProcessed: false
  },
  pollUrl: function() {
    return `/enrollment/orders/${this.state.memberImport.order_id}/member_imports/${this.state.memberImport.id}`
  },
  setMemberImport: function(memberImport) {
    this.state.memberImport = memberImport
  },
  addRow: function(row) {
    this.state.rows.push(row)
  },
  addMember: function(member) {
    this.state.members.push(member)
  },
  hasMembers: function() {
    this.state.members > 0
  },
  setFile: function(file) {
    this.state.file = file
  },
  uploadSuccess: function() {
    this.state.uploadStatus = 'success'
  },
  uploadInProgress: function() {
    this.state.uploadStatus = 'in-progress'
  },
  uploadIdle: function() {
    this.state.uploadStatus = 'idle'
  },
  reset: function() {
    this.setMemberImport(null)
    this.state.problems = null
    this.state.problemsProcessed = false
    this.state.rows = []
    this.setFile(null)
    this.uploadIdle()
    this.state.members = []
  }
}
