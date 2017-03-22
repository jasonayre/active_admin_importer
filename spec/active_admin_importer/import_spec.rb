require 'spec_helper'

describe ActiveAdminImporter::Import do
  let(:csv_file_path) { CSV_FILES[0] }
  let(:csv_file) { ::ActiveAdminImporter::CsvFile.read(csv_file_path) }
  let(:controller) { instance_double("controller") }
  let(:target_model) { double("target_model") }
  subject { ::ActiveAdminImporter::Import.new(csv_file, :controller => controller, :target_model => target_model) }

  describe "#run" do
    let(:first_row) { csv_file.find_row_by_number(1) }
    let(:rows) { [1, 2].map{ |number| csv_file.find_row_by_number(number) } }

    it {
      rows.each { |row| expect(target_model).to receive(:create!).with(row.to_hash) }
      subject.run
    }
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
          :target_model => target_model,
          :required_headers => required_headers
        )
      }

      it { expect(subject.valid?).to eq true }

      context "invalid headers" do
        subject {
          ::ActiveAdminImporter::Import.new(
            csv_file,
            :controller => controller,
            :target_model => target_model,
            :required_headers => [required_headers, 'someotherheader'].flatten
          )
        }

        it { expect(subject.valid?).to eq false }
      end
    end
  end
end
