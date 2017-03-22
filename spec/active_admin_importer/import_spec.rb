require 'spec_helper'

describe ActiveAdminImporter::Import do
  let(:csv_file_path) { CSV_FILES[0] }
  let(:csv_file) { ::ActiveAdminImporter::CsvFile.read(csv_file_path) }
  let(:controller) { instance_double("controller") }
  let(:model) { double("model") }
  let(:rows) { [1, 2].map{ |number| csv_file.find_row_by_number(number) } }
  subject { ::ActiveAdminImporter::Import.new(csv_file, :controller => controller, :model => model) }

  describe "#run" do
    it {
      rows.each { |row| expect(model).to receive(:create!).with(row.to_hash) }
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
    context "no required headers" do
      it { expect(subject.valid?).to eq true }
    end

    context "requires headers to be present" do
      let(:required_headers){ ['sector', 'industry_group', 'industry', 'sub_industry'] }

      subject {
        ::ActiveAdminImporter::Import.new(
          csv_file,
          :controller => controller,
          :model => model,
          :required_headers => required_headers
        )
      }

      it { expect(subject.valid?).to eq true }

      context "invalid headers" do
        subject {
          ::ActiveAdminImporter::Import.new(
            csv_file,
            :controller => controller,
            :model => model,
            :required_headers => [required_headers, 'someotherheader'].flatten
          )
        }

        it { expect(subject.valid?).to eq false }
      end
    end
  end
end
