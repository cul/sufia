module Sufia::WorksController::CollectionBehavior
  extend ActiveSupport::Concern

  def members_search_params_logic
    @members_search_params_logic ||= [:include_work_ids]
  end

  def members_search_params_logic=search_params_logic
    @members_search_params_logic = search_params_logic
  end

  # Because this has details and members, cannot rely on generic impl
  def query_collection_members
    solr_params =  {}

    # run the solr query to find the collection members
    query = collection_member_search_builder.with(solr_params).query
    @member_response = repository.search(query)
    puts @member_response.inspect
    @member_docs = @member_response.documents
  end

  def collection_member_search_builder_class
    Sufia::SearchBuilder
  end

  def collection_member_search_builder
    @collection_member_search_builder ||= collection_member_search_builder_class.new(collection_member_search_logic, @generic_work).tap do |builder|
      builder.current_ability = current_ability
    end
  end

  # Defines which search_params_logic should be used when searching for Collection members
  def collection_member_search_logic
    members_search_params_logic + [:add_access_controls_to_solr_params]
  end

  def collection_params
    form_class.model_attributes(
      params.require(:collection).permit(:title, :description, :members, part_of: [],
        contributor: [], creator: [], publisher: [], date_created: [], subject: [],
        language: [], rights: [], resource_type: [], identifier: [], based_near: [],
        tag: [], related_url: [])
    )
  end
end