module ActiveAdminImporter
  class Definition
    def initialize(_name=:records, _controller,  &block)
      @_name = _name
      @_action = "import_#{@_name}"
      @_form_action = "upload_#{@_name}"
      @_view = "admin/csv/upload"
      @_required_headers ||= []
      @_controller = _controller
      @_model = @_controller.resource_class
      @_each_row = lambda{ |params| @_model.create!(params) }
      self.instance_eval(&block) if block_given?
    end

    def [](val)
      self.instance_variable_get(:"@_#{val}")
    end

    def action(val)
      @_action = val
    end

    def after(&block)
      @_after = block
    end

    def before(&block)
      @_before = block
    end

    def key
      "#{self[:controller].name.underscore}/#{self[:name]}"
    end

    def model(val)
      @_model = val
    end

    def each_row(&block)
      @_each_row = block
    end

    def form_action(val)
      @_form_action = val
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
