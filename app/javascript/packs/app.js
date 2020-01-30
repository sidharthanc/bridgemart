import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

// Polyfills for IE11/Capybara. Required for StimulusJS.
import "core-js/fn/array/find"
import "core-js/fn/array/find-index"
import "core-js/fn/array/from"
import "core-js/fn/map"
import "core-js/fn/object/assign"
import "core-js/fn/promise"
import "core-js/fn/set"
import "element-closest"

const application = Application.start()
const context = require.context("../controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
