require 'rails'

module ActiveAdminCsvImporter
  class Engine < ::Rails::Engine
    config.mount_at = '/'

    config.after_initialize do
      require "active_admin"
      ::ActiveAdmin::DSL.send(:include, ActiveAdminCsvImporter::DSL)
    end
  end
end
