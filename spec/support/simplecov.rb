require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.start 'rails' do
  minimum_coverage 50
  maximum_coverage_drop 2 # allow for small variences

  add_filter 'lib/templates'
  add_filter { |src| src.filename =~ /application_(record|mailer|job|cable)/ }
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(
    [SimpleCov::Formatter::HTMLFormatter,
     SimpleCov::Formatter::CoberturaFormatter]
  )
  SimpleCov.coverage_dir('log/coverage') if ENV['CI']
  if ENV['SIMPLECOV_CHANGED'] # This has a tendency to break if run under CI
    add_group 'Changed' do |source_file|
      `git ls-files --exclude-standard --others \
        && git diff --name-only \
        && git diff --name-only --cached`.split("\n").detect do |filename|
        source_file.filename.ends_with?(filename)
      end
    end
  end
end
