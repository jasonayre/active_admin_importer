require 'rails'

module ActiveAdminImporter
  class Engine < ::Rails::Engine
    config.mount_at = '/'

    config.after_initialize do
      require "active_admin"
      ::ActiveAdmin::DSL.send(:include, ActiveAdminImporter::DSL)
    end
  end
end
