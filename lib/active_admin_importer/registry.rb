module ActiveAdminImporter
  class Registry < SimpleDelegator
    def initialize
      @obj = {}
    end

    def [](val)
      @obj[val]
    end
  end
end
