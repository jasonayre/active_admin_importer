require 'csv'
require 'digest'

module ActiveAdminImporter
  class CsvFile < SimpleDelegator
    CSV_READ_OPTIONS = { :headers => true, :header_converters => :symbol }
    BOM = "\xEF\xBB\xBF".force_encoding('UTF-8')

    def self.read(path)
      new(::File.new(path))
    end

    def csv_read_options
      @csv_read_options ||= begin
        h = {**CSV_READ_OPTIONS}
        h.merge(:encoding => 'bom|utf-8') if has_bom?
        h
      end
    end

    def initialize(descriptor)
      @descriptor = descriptor
      # @descriptor = ::File.new(descriptor, encoding: 'bom|utf-8')
    end

    def __getobj__
      @descriptor
    end

    def has_bom?
      headers[0].starts_with?(BOM)
    end

    def each_row(&block)
      if has_bom?
        ::CSV.each_row_with_bom(self, CSV_READ_OPTIONS.dup, &block)
      else
        ::CSV.parse(self, CSV_READ_OPTIONS.dup, &block)
      end
    end

    def find_row_by_number(number)
      result = ::CSV.foreach(self, csv_read_options).with_index do |row, i|
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
