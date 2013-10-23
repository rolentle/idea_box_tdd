gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './test/test_helper'
require './lib/ideabox/idea'
require './lib/ideabox/idea_store'

class IdeaStoreTest < Minitest::Test

  def teardown
    IdeaStore.delete_all
  end

  def test_save_retrive_ideas
    idea = Idea.new("celebrate", "with champagne")
    id = IdeaStore.save(idea)

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.find(id)
    assert_equal "celebrate", idea.title
    assert_equal "with champagne", idea.description
  end

  def test_save_and_retrive_one_of_many
    idea1 = Idea.new("relax", "in the sauna")
    idea2 = Idea.new("inspiration", "looking at the stars")
    idea3 = Idea.new("career", "translate for the UN")
    id1 = IdeaStore.save(idea1)
    id2 = IdeaStore.save(idea2)
    id3 = IdeaStore.save(idea3)

    assert_equal 3, IdeaStore.count

    idea = IdeaStore.find(id2)
    assert_equal "inspiration", idea.title
    assert_equal "looking at the stars", idea.description
  end

  def test_update_idea
    idea = Idea.new("drink", "tomato juice")
    id = IdeaStore.save(idea)

    idea = IdeaStore.find(id)
    idea.title = "cocktails"
    idea.description = "spicy tomato juice with vodka"

    IdeaStore.save(idea)

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.find(id)
    assert_equal "cocktails", idea.title
    assert_equal "spicy tomato juice with vodka",idea.description
  end

  def test_delete_an_idea
    id1 = IdeaStore.save Idea.new "song", "99 bottles of beer"
    id2 = IdeaStore.save Idea.new "gift", "mickey mouse belt"
    id3 = IdeaStore.save Idea.new "dinner", "cheeseburger with bacon and avacado"

    assert_equal ["song", "gift", "dinner"], IdeaStore.all.map(&:title)
    IdeaStore.delete(id2)
    assert_equal ["song", "dinner"], IdeaStore.all.map(&:title)
  end

  def test_find_by_title
    IdeaStore.save Idea.new("dance", "like it's the 80s")
    IdeaStore.save Idea.new("sleep", "like a baby")
    IdeaStore.save Idea.new("dream", "like anything is possible")

    idea = IdeaStore.find_by_title("sleep")

    assert_equal "like a baby", idea.description
  end

  def test_find_all_by_tag
    IdeaStore.save Idea.new("song", "fat lip", "music, punk")
    IdeaStore.save Idea.new("other song", "I am a God", "music, rap")
    IdeaStore.save Idea.new("person", "sid vicious", "person, punk")

    music_ideas = IdeaStore.find_all_by_tag("music")
    person_idea = IdeaStore.find_all_by_tag("person")

    assert_equal 2, music_ideas.count
    assert_equal 1, person_idea.count
  end
end
