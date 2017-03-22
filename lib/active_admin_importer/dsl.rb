module ActiveAdminImporter
  module DSL
    def define_import_for(name='records', **options, &block)
      options[:action] ||= "import_#{name}"
      options[:form_action] ||= "upload_#{name}"
      options[:view] ||= "admin/csv/upload"
      options[:required_headers] ||= []

      action_item :edit, :only => :index do
        link_to options[:action].titleize, :action => options[:form_action]
      end

      collection_action(options[:form_action]) do
        render options[:view], :locals => { :target_action => options[:action] }
      end

      collection_action(options[:action], :method => :post) do
        import = ::ActiveAdminImporter.import(params[:dump][:file], :model => active_admin_config.resource_class, :controller => self, &block)
        import.run if import.valid?
        notice = import.valid? ? "CSV imported successfully!" : "Bad column headers, expected #{import.required_headers} got #{import.csv_file_headers}"
        redirect_to collection_path, notice: notice
      end
    end
  end
end
