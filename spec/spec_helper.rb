$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'active_admin_importer'
require 'rails'
require 'pry'

::Rails.logger = Logger.new(STDOUT)

CSV_FILES = ::Dir["#{::File.dirname(__FILE__)}/support/*.csv"]
