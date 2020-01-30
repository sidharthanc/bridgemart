# lib/tasks/factory_bot.rake
namespace :factory_bot do
  desc "Verify that FactoryBot factories are valid"
  task :lint, [:path] => :environment do |_t, args|
    conn = ActiveRecord::Base.connection
    conn.transaction do
      if args.path.present?
        factories = FactoryBot.factories.select do |factory|
          factory.name.to_s =~ /#{args.path[0]}/
        end
        FactoryBot.lint factories, traits: true
      else
        FactoryBot.lint traits: true
      end

      raise ActiveRecord::Rollback
    end
  end
end
