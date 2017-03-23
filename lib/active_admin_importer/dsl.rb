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
        binding.pry
        _import = ::ActiveAdminImporter.import(params[:dump][:file],
                                              :model => active_admin_config.resource_class,
                                              :controller => self,
                                              :required_headers => options[:required_headers],
                                              &block)
        puts "HELLO?"
        # puts import.valid?
        # binding.pry
        # import.run if import.valid?
        # puts collection_path
        # puts import.result
        redirect_to collection_path, notice: "hello"
      end
    end
  end
end
