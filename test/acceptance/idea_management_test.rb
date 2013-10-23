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

  def test_ranking_ideas
    id1 = IdeaStore.save Idea.new('fun', 'ride horse')
    id2 = IdeaStore.save Idea.new('vacation', 'camping in the mountains')
    id3 = IdeaStore.save Idea.new('write', 'a book about being brave')

    visit '/'

    idea = IdeaStore.all[1]
    5.times do
      idea.like!
    end

    IdeaStore.save(idea)

    within("#idea_#{id2}") do
      3.times do
	click_button "+"
      end
    end

    within("#idea_#{id3}") do
      click_button "+"
    end

    ideas = page.all('li')
    assert_match /camping in the mountains/, ideas[0].text
    assert_match /a book about being brave/, ideas[1].text
    assert_match /ride horse/, ideas[2].text
  end

  def test_create_idea_with_tag
    visit '/'

    fill_in 'title', :with => 'stuff'
    fill_in 'description', :with => 'horse'
    fill_in 'tags', :with => 'pony, betting'
    click_button "Save"

    assert page.has_content?('pony, betting'), "tags are no appearing"
  end

  def test_clicking_tags_takes_you_to_tag_page
    id1 = IdeaStore.save Idea.new("childcare","candy", "my idea, stupid")
    IdeaStore.save Idea.new("cooking","creme brulee", "my idea, good")
    IdeaStore.save Idea.new("fitness","crosstfit", "bryana's idea, good")

    visit '/'

    within "#idea_#{id1}" do
      click_link "my idea"
    end

    assert page.has_content?("candy"), "Where is candy?"
    assert page.has_content?("cooking"), "Do you smell what I am cooking?"
    refute page.has_content?("fitness"), "Bryana has stupid ideas"
  end

  def test_ideas_are_sorted_on_the_page
    IdeaStore.save Idea.new("cooking","creme brulee", "my idea, good")
    IdeaStore.save Idea.new("fitness","crosstfit", "not my idea, good")
    IdeaStore.save Idea.new("stuff","example")

    visit '/sorted_tags'

    within '#tag_good' do
      assert page.has_content? "cooking"
      assert page.has_content? "fitness"
    end

    within '#tag_my_idea' do
      assert page.has_content? "cooking"
      refute page.has_content? "fitness"
    end

    within(:css,"ul#tag_not_my_idea") do
      refute page.has_content? "cooking"
      assert page.has_content? "fitness"
    end

    within( :css, "ul#tag_no_tags") do
      assert page.has_content? "stuff"
      refute page.has_content? "cooking"
      refute page.has_content? "fitness"
    end
  end
end

