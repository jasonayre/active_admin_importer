require 'csv'
require 'digest'

module ActiveAdminImporter
  class CsvFile < SimpleDelegator
    CSV_READ_OPTIONS = { :headers => true, :header_converters => :symbol }
    BOM = "\xEF\xBB\xBF".force_encoding('UTF-8')

    def self.read(path)
      new(::File.new(path))
    end

    def initialize(descriptor)
      @descriptor = descriptor
    end

    def __getobj__
      @descriptor
    end

    def has_bom?
      @_has_bom ||= headers.any? {|header| header.starts_with?(BOM) }
    end

    def each_row(&block)
      if has_bom?
        ::CSV.each_row_with_bom(self, CSV_READ_OPTIONS, &block)
      else
        ::CSV.parse(self, CSV_READ_OPTIONS, &block)
      end
    end

    def find_row_by_number(number)
      result = ::CSV.foreach(self, CSV_READ_OPTIONS).with_index do |row, i|
        return row if i == number - 1
      end

      result
    end

    def headers
      @headers ||= ::CSV.open(@descriptor, 'r') { |csv| csv.first }
    end

    # read file in chunks for memory efficiency
    def md5
      @md5 ||= ::File.open(@descriptor, "rb") do |io|
        _md5 = ::Digest::MD5.new
        buffer = ""
        _md5.update(buffer) while io.read(4096, buffer)
        _md5
      end
    end
  end
end
