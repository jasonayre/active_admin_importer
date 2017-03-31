require 'spec_helper'
require 'pry'

describe ActiveAdminImporter::Definition do
  let(:csv_file_path) { CSV_FILES[0] }
  subject {
    ActiveAdminImporter::Definition.new do
      view "blah"
      required_headers :name
      permitted_headers :one, :two
      each_row do |model, params, controller

      end
    end
  }

  it { expect(subject[:view]).to eq "blah" }
  it { expect(subject[:required_headers]).to eq [:name] }
  it { expect(subject[:permitted_headers]).to eq [:one, :two] }
  it { expect(subject[:each_row]).to be_a(Proc) }


  # describe "#each_row" do
  #   let(:result) { [] }
  #
  #   it {
  #     subject.each_row{ |r| result << r }
  #     expect(result.first[:sector]).to eq "Consumer Discretionary"
  #   }
  # end
end
