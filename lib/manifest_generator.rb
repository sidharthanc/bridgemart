require 'dotenv/parser'
require 'erb'
require 'ostruct'

class ManifestGenerator
  REQUIRED_ENV_VARS = %w[RAILS_MASTER_KEY IMAGE].freeze
  ENVIRONMENTS_DIRECTORY = "config/deploy/environments/".freeze
  MANIFEST_TEMPLATE = "config/deploy/containers.yml.erb".freeze

  attr_reader :environment, :env

  def initialize(environment)
    raise ArgumentError, "Missing one or more ENV vars: #{REQUIRED_ENV_VARS}" unless required_env_vars_exist?

    @environment = environment
    @env = Dotenv::Parser.new(common_file).call
    @env.merge!(Dotenv::Parser.new(environment_file).call)
  end

  def generate
    ERB.new(manifest_template_file).result(OpenStruct.new(env: ENV.to_hash.merge(env)).instance_eval { binding })
  end

  private

    def required_env_vars_exist?
      REQUIRED_ENV_VARS.all? { |key| ENV.key?(key) }
    end

    def common_file
      path = ENVIRONMENTS_DIRECTORY + "common.env"
      File.read(path) if File.exist?(path)
    end

    def environment_file
      return unless environment

      path = ENVIRONMENTS_DIRECTORY + "#{environment}.env"
      File.read(path) if File.exist?(path)
    end

    def manifest_template_file
      File.read(MANIFEST_TEMPLATE) if File.exist? MANIFEST_TEMPLATE
    end
end
