require 'spec_helper'

describe ActiveAdminImporter::Import do
  let(:csv_file_path) { CSV_FILES[0] }
  let(:csv_file) { ::ActiveAdminImporter::CsvFile.read(csv_file_path) }
  let(:model) { double("model") }
  let(:controller_klass) { double(:controller_klass, :resource_class => model) }
  let(:controller) { double(:controller, :controller => controller_klass)}
  let(:required_headers) { [] }
  let(:definition) {
    ::ActiveAdminImporter::Definition.new :products, controller_klass do
      view "blah"
      required_headers *required_headers
      permitted_headers :one, :two
      # before { |import| import.instance_variable_set(:"@something", "anything") }

      each_row do |params, import|
        import.model.create!(params)
      end
    end
  }

  let(:rows) { [1, 2].map{ |number| csv_file.find_row_by_number(number) } }
  subject { ::ActiveAdminImporter::Import.new(csv_file, :controller => controller, :definition => definition) }

  describe "#run" do
    let(:model) {
      _model = double("model", :create! => lambda{|params, definition| })
      _model
    }

    it {
      rows.each { |row| expect(definition[:each_row]).to receive(:call).with(row.to_hash, subject) }
      subject.run
    }
  end

  describe "#result" do
    before do
      rows.each { |row| expect(model).to receive(:create!).with(row.to_hash) }
    end

    context "does not have failures" do
      it {
        subject.run
        expect(subject.result).to eq "2 / 2 imported successfully"
      }
    end

    context "has failures" do
      before do
        rows.each { |row| allow(model).to receive(:create!).with(row.to_hash).and_raise(StandardError.new("error")) }
      end

      it {
        subject.run
        expected_message = "Failed to import rows: 1,2\n0 / 2 imported successfully"
        expect(subject.result).to eq expected_message
      }
    end
  end

  describe "#valid?" do
    subject {
      ::ActiveAdminImporter::Import.new(
        csv_file, :controller => controller, :definition => definition
      )
    }

    context "no required headers" do
      it { expect(subject.valid?).to eq true }
    end

    context "requires headers to be present" do
      let(:required_headers){ ['sector', 'industry_group', 'industry', 'sub_industry'] }

      it { expect(subject.valid?).to eq true }

      context "invalid headers" do
        before { required_headers << 'someotherheader' }

        it { expect(subject.valid?).to eq false }
      end
    end
  end
end
