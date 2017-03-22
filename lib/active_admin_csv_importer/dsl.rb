module ActiveAdminCsvImporter
  module DSL
    def active_admin_csv_importer(view: 'admin/csv/upload_csv', &block)
      action_item :edit, :only => :index do
        link_to "Import #{active_admin_config.resource_name.to_s.pluralize}", :action => 'upload_csv'
      end

      collection_action :upload_csv do
        render view
      end

      collection_action :import_csv, :method => :post do
        ::ActiveAdminCsvImporter.import(params[:dump][:file], :model => active_admin_config.resource_class, :controller => self, &block)
        redirect_to collection_path, notice: "CSV imported successfully!"
      end
    end

    def defined_import_for(name='records', **options, &block)
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
        if block_given?
          ::ActiveAdminCsvImporter.import(params[:dump][:file], :model => active_admin_config.resource_class, :controller => self, &block)
        else
          ::ActiveAdminCsvImporter.import(params[:dump][:file], :model => active_admin_config.resource_class, :controller => self)
        end
        # CsvDb.convert_save(active_admin_config.resource_class, params[:dump][:file], self, &block)
        redirect_to collection_path, notice: "CSV imported successfully!"
      end
    end
  end
end
