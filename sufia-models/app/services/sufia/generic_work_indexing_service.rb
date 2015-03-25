module Sufia
  class GenericWorkIndexingService < ActiveFedora::IndexingService
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc[Solrizer.solr_name('label')] = object.label
        solr_doc['all_text_timv'] = object.full_text.content
      end
    end
  end
end