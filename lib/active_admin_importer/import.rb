module ActiveAdminImporter
  class Import
    attr_reader :current_row, :csv_file

    def initialize(csv_file, controller:, model:, required_headers:[], &block)
      @csv_file = ::ActiveAdminImporter::CsvFile.new(csv_file)
      @controller = controller
      @model = model
      @required_headers = required_headers
      @current_row = 0
      @block = block if block_given?
      notices << invalid_import_notice unless self.valid?
    end

    def failed_rows
      @failed_rows ||= []
    end

    def notices
      @notices ||= []
    end

    def run
      log_info("STARTING IMPORT")

      ::CSV.parse(@csv_file, :headers => true, header_converters: :symbol) do |row|
        begin
          process_row(row)
        rescue => e
          record_failure(row, e)
        end
      end

      log_error("FAILED TO PARSE ROWS #{failed_rows}") if failed_rows.any?
      log_info("FINISHED IMPORT")
    end

    def valid?
      @required_headers.all?{ |header| @csv_file.headers.include?(header) }
    end

    private

    def invalid_import_notice
      "CSV imported successfully!" : "Bad column headers, expected #{@required_headers} got #{@csv_file.headers}"
    end

    def processed_row_count
      @processed_row_count ||= 0
    end

    def process_row(row)
      @current_row += 1
      log_info("IMPORTING ROW - #{current_row}")
      data = row.to_hash

      if data.present?
        if @block
          @block.call(@model, data, @controller)
        else
          @model.create!(data)
        end
      end
    end

    def record_failure(row, e)
      log_error("FAILED TO PARSE ROW #{current_row}")
      failed_rows << current_row
      log_error("ROW\##{current_row} - #{e.message}")
      ::Rails.logger.error(e.message)
    end

    def log_error(message)
      ::Rails.logger.error("[IMPORT: #{@csv_file.md5}]: #{message}")
    end

    def log_info(message)
      ::Rails.logger.info("[IMPORT: #{@csv_file.md5}]: #{message}")
    end
  end
end
