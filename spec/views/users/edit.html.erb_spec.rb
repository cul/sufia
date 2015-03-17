require 'spec_helper'

describe 'users/edit.html.erb', type: :view do
  let(:user) { stub_model(User, user_key: 'mjg') }

  before do
    allow(view).to receive(:signed_in?).and_return(true)
    allow(view).to receive(:current_user).and_return(user)
    assign(:user, user)
    assign(:followers, [])
    assign(:following, [])
    assign(:trophies, [])
    assign(:events, [])
  end

  it "shows an ORCID field" do
    render
    expect(rendered).to match(/ORCID Profile/)
  end

  context 'with Zotero integration enabled' do
    before do
      allow(Sufia.config).to receive(:arkivo_api) { true }
    end

    it 'shows a Zotero label' do
      render
      puts rendered
      expect(rendered).to match(/Zotero/)
    end

    it 'shows the Zotero image with alt text' do
      render
      expect(rendered).to have_css('img#zotero')
    end

    context 'with no existing token' do
      it 'shows a Zotero OAuth button' do
        render
        expect(rendered).to have_css('a#zotero')
      end
    end

    context 'with an existing token, in the production env' do
      before do
        # stub the token behavior
        # set env to prod
      end

      it 'shows a Zotero OAuth button' do
        render
        expect(rendered).to have_css('a#zotero')
      end
    end

    context 'with an existing token, in the dev env' do
      before do
        # stub the token behavior
        # set env to dev
        # render
      end

      it 'hides a Zotero OAuth button' do
        expect(rendered).not_to have_css('a#zotero')
      end

      it 'shows the zotero_pin text field'
    end
  end

  context 'with Zotero integration disabled' do
    before do
      allow(Sufia.config).to receive(:arkivo_api) { false }
    end

    it 'hides a Zotero OAuth button' do
      render
      expect(subject).not_to have_css('a#zotero')
    end
  end
end
