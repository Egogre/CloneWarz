ENV['RACK_ENV'] = 'test-db'

require './test/test_helper'
require 'bundler'
Bundler.require
require 'rack/test'
require 'capybara'
require 'capybara/dsl'

require './lib/app'

Capybara.app = CloneWarzApp

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers =>  { 'User-Agent' => 'Capybara' })
end

class PageListingTest < Minitest::Test
  include Capybara::DSL

  def setup
    Pages.database
    Pages.create
  end

  def test_it_lists_all_pages
    # data = {
    #   title: "Home",
    #   url: "/",
    #   heading: "Home",
    #   img: "",
    #   body: "Welcome to Denver Bike Depot!",
    #   carousel_id: nil
    # }
    # Pages.table.insert(data)
    # data.merge!({title: "About"})
    # Pages.table.insert(data)
    # data.merge!({title: "Mission, Vision, and Values"})
    # Pages.table.insert(data)
    # data.merge!({title: "History"})
    # Pages.table.insert(data)
    # data.merge!({title: "Staff & Board"})
    # Pages.table.insert(data)
    # data.merge!({title: "Contact & Hours"})
    # Pages.table.insert(data)
    # data.merge!({title: "Privacy Policy"})
    # Pages.table.insert(data)

    visit '/admin'

    assert page.has_content?("All Pages"), "Page listing cannot be found"
    assert page.has_content?("Home"), "Home listing doesn't appear"
    assert page.has_content?("About"), "About listing doesn't appear"
    assert page.has_content?("Mission, Vision and Values"), "Mission, Vision and Values listing doesn't appear"
    assert page.has_content?("History"), "History listing doesn't appear"
    assert page.has_content?("Staff & Board"), "Staff & Board listing doesn't appear"
    assert page.has_content?("Contact & Hours"), "Contact & Hours listing doesn't appear"
    assert page.has_content?("Privacy Policy"), "Privacy Policy listing doesn't appear"
  end

  def test_an_admin_can_click_a_link_and_go_to_edit_screen
    visit '/admin'

    assert page.has_content?("About"), "About listing doesn't appear"

    test_page = Pages.find_by_url("/about")

    within("#page#{test_page.id}") do
      find(".edit").click
    end

    assert_equal 200, page.status_code
    assert page.has_content?("Edit the About page")

    fill_in 'body', :with => 'New body.'
    fill_in 'heading', :with => 'New heading.'
    click_button 'Edit it!'

    assert /New body./ =~ Pages.find_by_id(test_page.id).body
    assert /New heading./ =~ Pages.find_by_id(test_page.id).heading

    Pages.update(test_page)

  end
end
