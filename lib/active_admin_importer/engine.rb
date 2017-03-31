require 'rails'

module ActiveAdminImporter
  class Engine < ::Rails::Engine
    config.mount_at = '/'
  end
end
