module ActiveAdminImporter
  class Import
    attr_reader :controller, :current_row, :csv_file, :definition, :model

    def initialize(csv_file, definition:, controller:)
      @csv_file = ::ActiveAdminImporter::CsvFile.new(csv_file)
      @controller = controller
      @definition = definition
      @model = definition[:model]
      @required_headers = definition[:required_headers]
      @current_row = 0
    end

    def failed_rows
      @failed_rows ||= []
    end

    def headers
      @headers ||= @csv_file.headers
    end

    def md5
      @md5 ||= @csv_file.md5
    end

    def run
      run_before_callback if run_before_callback?
      log_info("STARTING IMPORT")

      @csv_file.each_row do |row|
        begin
          process_row(row)
        rescue => e
          record_failure(row, e)
        end
      end

      log_error("FAILED TO PARSE ROWS #{failed_rows}") if failed_rows.any?
      log_info("FINISHED IMPORT")
      run_after_callback if run_after_callback?
    end

    def result
      @result ||= begin
        _result = []
        _result << "Bad column headers, expected #{@required_headers} got #{@csv_file.headers}" unless self.valid?
        _result << "Failed to import rows: #{failed_rows.join(',')}" if failed_rows.any?
        _result << "#{current_row - failed_rows.length} / #{current_row} imported successfully" if current_row > 0
        _result.join("\n")
      end
    end

    def valid?
      @required_headers.all? do |header|
        self.headers.include?(header) || self.headers.include?(::ActiveAdminImporter::CsvFile::BOM + header)
      end
    end

    private

    def log_error(message)
      ::Rails.logger.error("[IMPORT: #{self.md5}]: #{message}")
    end

    def log_info(message)
      ::Rails.logger.info("[IMPORT: #{self.md5}]: #{message}")
    end

    def process_row(row)
      @current_row += 1
      log_info("IMPORTING ROW - #{current_row}")
      data = row.to_hash

      if data.present?
        data = @definition[:transformer].new(data).to_hash if @definition[:transformer]
        data = @definition[:transform].call(data) if @definition[:transform]
        @definition[:each_row].call(data, self)
      end
    end

    def record_failure(row, e)
      log_error("FAILED TO PARSE ROW #{current_row}")
      failed_rows << current_row
      log_error("ERROR_ON_ROW\##{current_row} - #{e.message}")
      ::Rails.logger.error(e.message)
    end

    def run_after_callback
      self.instance_eval(&@definition[:after])
    end

    def run_after_callback?
      @definition[:after]
    end

    def run_before_callback
      self.instance_eval(&@definition[:before])
    end

    def run_before_callback?
      @definition[:before]
    end
  end
end
