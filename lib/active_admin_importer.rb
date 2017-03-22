require "active_admin_importer/version"
require "active_support/all"
require "active_admin_importer/engine"

module ActiveAdminImporter
  extend ::ActiveSupport::Autoload

  autoload :Engine
  autoload :CsvFile
  autoload :Import

  def self.import(csv_file, **options, &block)
    if block_given?
      ::ActiveAdminImporter::Import.new(csv_file, **options, &block)
    else
      ::ActiveAdminImporter::Import.new(csv_file, **options)
    end
  end
end
