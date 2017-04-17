module ActiveAdminImporter
  module DSL
    def define_import_for(name='records', &block)
      definition = ::ActiveAdminImporter::Definition.new(name, self.controller, &block)

      action_item :edit, :only => :index do
        link_to definition[:action].titleize, :action => definition[:form_action]
      end

      collection_action(definition[:form_action]) do
        render definition[:view], :locals => { :target_action => definition[:action] }
      end

      collection_action(definition[:action], :method => :post) do
        parent if parent?
        import = ::ActiveAdminImporter.import(params[:dump][:file], :controller => self, :definition => definition)
        redirect_to collection_path(), alert: import.result
      end

      ::ActiveAdminImporter.register(definition)
    end
  end
end
