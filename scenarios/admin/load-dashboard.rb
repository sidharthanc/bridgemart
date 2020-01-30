ENV['WATIR_HOST'] = 'localhost:3000'

# Initalize the Browser
browser = Watir::Browser.new

# Navigate to Page
browser.goto ENV['WATIR_HOST']
