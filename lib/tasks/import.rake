namespace :import do
  desc 'Import Employer Legacy Data from BridgeMart'
  task :employer, %i[import_file] => [:environment] do |_, args|
    import_file = args[:import_file]

    employer = Employer.new(import_file, notify: notify?(args), dryrun: dryrun?(args))
    employer.import
  end

  desc 'Import Invoice Legacy Data from BridgeMart'
  task :invoice, %i[import_file] => [:environment] do |_, args|
    import_file = args[:import_file]

    invoice = Invoice.new(import_file, dryrun: dryrun?(args))
    invoice.import
  end

  desc 'Import Card Legacy Data from BridgeMart'
  task :card, %i[import_file] => [:environment] do |_, args|
    import_file = args[:import_file]

    card = Card.new(import_file, dryrun: dryrun?(args))
    card.import
  end

  desc 'Import Usage Legacy Data from BridgeMart'
  task :usage, %i[import_file] => [:environment] do |_, args|
    import_file = args[:import_file]

    card_usage = CardUsage.new(import_file, dryrun: dryrun?(args))
    card_usage.import
  end

  desc 'Set multiple organizations imported to a broker user'
  task broker: :environment do
    broker = OrganizationBroker.new
    broker.process
  end

  desc 'Update card remaining balances from CSV'
  task :update_remaining_card_balance, %i[import_file] => [:environment] do |_, args|
    import_file = args[:import_file]

    card = UpdateRemainingCardBalance.new(import_file)
    card.import
  end

  def notify?(args)
    args.extras.include? 'notify'
  end

  def dryrun?(args)
    args.extras.include? 'dryrun'
  end
end
