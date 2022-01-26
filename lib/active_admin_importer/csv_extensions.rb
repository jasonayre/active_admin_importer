class CSV
  def self.open_with_bom(file, options={}, &block)
    encoding = options.delete(:encoding)
    ::File.open(file, "r:#{encoding}") do |fd|
      yield ::CSV.new(fd, options)
    end
  end

  def self.each_row_with_bom(file, options={}, &block)
    ::CSV.open_with_bom(file, {**options, encoding:  'bom|utf-8'}) { |csv| csv.each(&block) }
  end
end
