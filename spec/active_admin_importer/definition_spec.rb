require 'spec_helper'
require 'pry'

describe ActiveAdminImporter::Definition do
  let(:csv_file_path) { CSV_FILES[0] }
  let(:model) { double(:model) }
  let(:controller_klass) { double(:controller, :resource_class => model) }
  subject {
    ::ActiveAdminImporter::Definition.new :products, controller_klass do
      view "blah"
      required_headers :name
      permitted_headers :one, :two
      each_row do |model, params, controller|

      end
    end
  }

  it { expect(subject[:view]).to eq "blah" }
  it { expect(subject[:required_headers]).to eq [:name] }
  it { expect(subject[:permitted_headers]).to eq [:one, :two] }
  it { expect(subject[:each_row]).to be_a(Proc) }
end
