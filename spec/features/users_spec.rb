require 'spec_helper'

describe "User Profile" do

  before do
    sign_in :curator
  end

  it "should be displayed" do
    click_link "curator1@example.com"
    page.should have_content "Edit Your Profile"
  end

  it "should be editable" do
    click_link "curator1@example.com"
    click_link "Edit Your Profile"
    fill_in 'user_twitter_handle', with: 'curatorOfData'
    click_button 'Save Profile'
    page.should have_content "Your profile has been updated"
    page.should have_content "curatorOfData"
  end

  it "should display all users" do
    click_link "curator1@example.com"
    click_link "View Users"
    page.should have_xpath("//td/a[@href='/users/curator1@example-dot-com']")
  end
end
