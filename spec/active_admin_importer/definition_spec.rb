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
      each_row do |params, import|
        import.model.create(params)
      end
    end
  }

  it { expect(subject[:view]).to eq "blah" }
  it { expect(subject[:required_headers]).to eq [:name] }
  it { expect(subject[:each_row]).to be_a(Proc) }
end
