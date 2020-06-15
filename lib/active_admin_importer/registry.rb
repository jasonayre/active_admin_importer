module ActiveAdminImporter
  class Registry < SimpleDelegator
    def initialize
      @obj = {}
    end

    def __getobj__
      @obj
    end

    def [](val)
      @obj[val]
    end
  end
end
