require './test/test_helper'
require 'bundler'
Bundler.require
require 'rack/test'
require 'capybara'
require 'capybara/dsl'

require './lib/app'

Capybara.app = IdeaboxApp

Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app, :headers => { 'User-Agent' => 'Capybara' } )
end

class IdeaManagementTest < Minitest::Test
  include Capybara::DSL

  def teardown
    IdeaStore.delete_all
  end

  def test_manage_ideas
    IdeaStore.save Idea.new "laundry", "buy more socks"
    IdeaStore.save Idea.new "groceries", "macaroni, cheese"

    visit '/'
    assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
    assert page.has_content?("macaroni"), "Decoy idea (macaroni) is not on page"

    fill_in 'title', :with => 'eat'
    fill_in 'description', :with=> 'chocolate chip cookies'
    click_button 'Save'
    assert page.has_content?('chocolate chip cookies'), 'Idea is not on page'

    idea = IdeaStore.find_by_title('eat')

    within("#idea_#{idea.id}") do
      click_link 'Edit'
    end

    assert_equal 'eat', find_field('title').value
    assert_equal 'chocolate chip cookies', find_field('description').value

    fill_in 'title', :with => 'eat'
    fill_in 'description', :with => 'chocolate chip oatmeal cookies'
    click_button 'Save'

    assert page.has_content?('chocolate chip oatmeal cookies'), 'Updated idea is not on page'

    assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page"
    assert page.has_content?("macaroni"), "Decoy idea (macaroni) is not on page"

    refute page.has_content?('chocolate chip cookies'), 'Original idea is on page still'

    within("#idea_#{idea.id}") do
      click_button 'Delete'
    end

    refute page.has_content?("chocolate chip oatmeal cookies"), "Updated idea is not on page"

    assert page.has_content?("buy more socks"), "Decoy idea (socks) is not on page after delete"
    assert page.has_content?("macaroni, cheese"), "Decoy idea (macaroni) is not on page after delete"
  end

end
