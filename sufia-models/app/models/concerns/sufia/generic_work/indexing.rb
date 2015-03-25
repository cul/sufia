module Sufia
  module GenericWork
    module Indexing
      extend ActiveSupport::Concern

      module ClassMethods
        # override the default indexing service
        def indexer
          Sufia::GenericWorkIndexingService
        end
      end
    end
  end
end
