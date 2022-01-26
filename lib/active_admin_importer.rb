require "active_admin_importer/version"
require "active_support/all"
require "active_admin_importer/engine"
require "pry"
require "active_admin_importer/csv_extensions"

module ActiveAdminImporter
  extend ::ActiveSupport::Autoload

  autoload :Definition
  autoload :DSL
  autoload :Engine
  autoload :CsvFile
  autoload :Import
  autoload :Registry

  def self.import(csv_file, **options, &block)
    io = csv_file.is_a?(::ActionDispatch::Http::UploadedFile) ? csv_file.tempfile : csv_file

    _import = if block_given?
      ::ActiveAdminImporter::Import.new(io, **options, &block)
    else
      ::ActiveAdminImporter::Import.new(io, **options)
    end

    _import.run if _import.valid?
    _import
  end

  def self.[](val)
    registry[val]
  end

  def self.registry
    @registry ||= ::ActiveAdminImporter::Registry.new
  end

  def self.register(definition)
    registry[definition.key] = definition
  end
end

unless ENV["SKIP_ACTIVE_ADMIN_REQUIRE"]
  require 'activeadmin' unless defined?(::ActiveAdmin)
  ::ActiveAdmin::DSL.send(:include, ActiveAdminImporter::DSL)
end
