module Sufia
  module Catalog
    extend ActiveSupport::Concern
    included do
      self.search_params_logic += [:only_sufia_models]
    end
  end
end
