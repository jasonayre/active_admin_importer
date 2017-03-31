module ActiveAdminImporter
  class Definition
    def initialize(&block)
      self.instance_eval(&block) if block_given?
    end

    def [](val)
      self.instance_variable_get(:"@_#{val}")
    end

    def each_row(&block)
      @_each_row = block
    end

    def permitted_headers(*_values)
      @_permitted_headers = _values
    end

    def required_headers(*_values)
      @_required_headers = _values
    end

    def view(value)
      @_view = value
    end
  end
end
