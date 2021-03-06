gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './test/test_helper'
require './lib/ideabox/idea'

class IdeaTest < Minitest::Test
  def test_basic_idea
    idea = Idea.new("title", "description")
    assert_equal "title", idea.title
    assert_equal "description", idea.description
  end

  def test_idea_can_be_liked
    idea = Idea.new( "diet", "carrots and cucumbers")
    assert_equal 0, idea.rank
    idea.like!
    assert_equal 1, idea.rank
  end

  def test_idea_can_be_liked_more_than_once
    idea = Idea.new("exercise", "stickfighting")
    5.times do
      idea.like!
    end
    assert_equal 5, idea.rank
  end

  def test_ideas_can_be_sorted_by_rank
    diet = Idea.new("diet", "cabbage soup")
    exercise = Idea.new( "exercise", "long distance running")
    drink = Idea.new("drink", "carrot smoothy")

    exercise.like!
    exercise.like!
    drink.like!

    ideas = [diet, exercise, drink]

    assert_equal [diet, drink, exercise], ideas.sort
  end

  def test_ideas_have_tags
    vg = Idea.new("games", "halo", "halo, half life")

    assert_equal ['halo', 'half life'], vg.tags
  end

  def test_ideas_have_created_at_and_updated_at
    idea = Idea.new("hello", "world", "boring, test")

    assert idea.created_at, "No created at"
    assert idea.updated_at, "No updated at"
  end

end

