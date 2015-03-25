module Sufia
  module GenericWork
    extend ActiveSupport::Concern
    include Hydra::Collection
    include Sufia::ModelMethods
    include Sufia::Noid
    include Sufia::GenericFile::Permissions
    include Sufia::GenericFile::ProxyDeposit
    include Hydra::Collections::Collectible
    include Sufia::GenericFile::Batches
    include Sufia::GenericWork::Export
    include Sufia::GenericWork::Indexing

    included do
      before_save :update_permissions
      validates :title, presence: true
    end

    def update_permissions
      self.visibility = "open"
    end

    # Compute the sum of each file in the collection
    # Return an integer of the result
    def bytes
      members.reduce(0) { |sum, gf| sum + gf.content.size.to_i }
    end
  end
end