require "active_admin_csv_importer/version"
require "active_support/all"
require "active_admin_csv_importer/engine"

module ActiveAdminCsvImporter
  extend ::ActiveSupport::Autoload

  autoload :Engine
  autoload :CsvFile
  autoload :Import

  def self.import(csv_file, **options, &block)
    if block_given?
      ::ActiveAdminCsvImporter::Import.new(csv_file, **options, &block)
    else
      ::ActiveAdminCsvImporter::Import.new(csv_file, **options)
    end
  end
end
