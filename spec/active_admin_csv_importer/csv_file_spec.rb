require 'spec_helper'
require 'pry'

describe ActiveAdminCsvImporter::CsvFile do
  let(:csv_file_path) { CSV_FILES[0] }
  subject { ActiveAdminCsvImporter::CsvFile.read(csv_file_path) }

  it { expect(subject.md5).to be_instance_of(::Digest::MD5) }
  it { expect(subject.headers).to eq ['sector', 'industry_group', 'industry', 'sub_industry'] }

  describe "#each_row" do
    let(:result) { [] }

    it {
      subject.each_row{ |r| result << r }
      expect(result.first[:sector]).to eq "Consumer Discretionary"
    }
  end
end
