require "active_admin_importer/version"
require "active_support/all"
require "active_admin_importer/engine"

module ActiveAdminImporter
  extend ::ActiveSupport::Autoload

  autoload :DSL
  autoload :Engine
  autoload :CsvFile
  autoload :Import

  def self.import(csv_file, **options, &block)
    io = csv_file.is_a?(ActionDispatch::Http::UploadedFile) ? csv_file.tempfile : csv_file

    import = if block_given?
      ::ActiveAdminImporter::Import.new(io, **options, &block)
    else
      ::ActiveAdminImporter::Import.new(io, **options)
    end

    import.valid?
    import
    # puts import.valid?

  end
end