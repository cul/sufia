require 'spec_helper'

describe LocalAuthority, :type => :model do

  def harvest_nt
    LocalAuthority.harvest_rdf("genres", [fixture_path + '/genreForms.nt'])
  end

  def harvest_tsv
    LocalAuthority.harvest_tsv("geo", [fixture_path + '/cities15000.tsv'], prefix: 'http://sws.geonames.org/')
  end

  before :all do
    class MyTestRdfDatastream; end
  end

  after :all do
    Object.send(:remove_const, :MyTestRdfDatastream)
  end

  it "should harvest an ntriples RDF vocab" do
    harvest_nt
    expect(LocalAuthority.count).to eq(1)
    expect(LocalAuthorityEntry.count).to eq(6)
  end
  it "should harvest an RDF/XML vocab (w/ an alt predicate)" do
    LocalAuthority.harvest_rdf("langs", [fixture_path + '/lexvo.rdf'],
                               format: 'rdfxml',
                               predicate: ::RDF::URI("http://www.w3.org/2008/05/skos#prefLabel"))
    expect(LocalAuthority.count).to eq(1)
    expect(LocalAuthorityEntry.count).to eq(35)
  end
  it "should harvest TSV vocabs" do
    harvest_tsv
    expect(LocalAuthority.count).to eq(1)
    auth = LocalAuthority.where(name: "geo").first
    expect(LocalAuthorityEntry.where(local_authority_id: auth.id).first.uri).to start_with('http://sws.geonames.org/')
    expect(LocalAuthorityEntry.count).to eq(149)
  end

  describe "when vocabs are harvested" do

    let(:num_auths)   { LocalAuthority.count }
    let(:num_entries) { LocalAuthorityEntry.count }

    before do
      harvest_nt
      harvest_tsv
    end

    it "should not have any initial domain terms" do
      expect(DomainTerm.count).to eq(0)
    end

    it "should not harvest an RDF vocab twice" do
      harvest_nt
      expect(LocalAuthority.count).to eq(num_auths)
      expect(LocalAuthorityEntry.count).to eq(num_entries)
    end
    it "should not harvest a TSV vocab twice" do
      harvest_tsv
      expect(LocalAuthority.count).to eq(num_auths)
      expect(LocalAuthorityEntry.count).to eq(num_entries)
    end
    it "should register a vocab" do
      LocalAuthority.register_vocabulary(MyTestRdfDatastream, "geographic", "geo")
      expect(DomainTerm.count).to eq(1)
    end

    describe "when vocabs are registered" do

      before do
        LocalAuthority.register_vocabulary(MyTestRdfDatastream, "geographic", "geo")
        LocalAuthority.register_vocabulary(MyTestRdfDatastream, "genre", "genres")
      end

      it "should have some doamin terms" do
        expect(DomainTerm.count).to eq(2)
      end

      it "should return nil for empty queries" do
        expect(LocalAuthority.entries_by_term("my_test", "geographic", "")).to be_nil
      end
      it "should return an empty array for unregistered models" do
        expect(LocalAuthority.entries_by_term("my_foobar", "geographic", "E")).to eq([])
      end
      it "should return an empty array for unregistered terms" do
        expect(LocalAuthority.entries_by_term("my_test", "foobar", "E")).to eq([])
      end
      it "should return entries by term" do
        term = DomainTerm.where(model: "my_tests", term: "genre").first
        authorities = term.local_authorities.collect(&:id).uniq
        hits = LocalAuthorityEntry.where("local_authority_id in (?)", authorities).where("label like ?", "A%").select("label, uri").limit(25)
        expect(LocalAuthority.entries_by_term("my_tests", "genre", "A").count).to eq(6)
      end
    end
  end
end
