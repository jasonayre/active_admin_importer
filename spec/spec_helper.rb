$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
ENV['SKIP_ACTIVE_ADMIN_REQUIRE'] = "true"

require 'rails'
require 'pry'
require 'active_admin_importer'

::Rails.logger = Logger.new(STDOUT)
CSV_FILES = ::Dir["#{::File.dirname(__FILE__)}/support/*.csv"]
