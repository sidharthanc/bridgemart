namespace :test_cleanup do
  desc 'Clean Test junk so it does not get compiled into everything'
  task :clean do
    FileUtils.rm_rf('tmp')
    FileUtils.rm_rf('public/packs-test')
    FileUtils.rm_rf(Dir.glob('log/test.log'))
  end
end
