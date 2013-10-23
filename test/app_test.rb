require './test/test_helper'
require 'sinatra/base'
require 'rack/test'
require './lib/app'

class IdeaboxAppHelper < MiniTest::Test
  include Rack::Test::Methods

  def app
    IdeaboxApp
  end

  def teardown
    IdeaStore.delete_all
  end

  def test_idea_list
    IdeaStore.save Idea.new("dinner", "spaghetti and meatballs")
    IdeaStore.save Idea.new("drinks", "imported beers")
    IdeaStore.save Idea.new("movie", "The Matrix")

    get '/'

    foo= [/dinner/, /spaghetti/,
     /drinks/, /imported beers/i,
    /movie/, /The Matrix/]
    foo.each do |content|
      assert_match content, last_response.body
    end
  end

  def test_edit_idea
    id = IdeaStore.save Idea.new('sing', 'happy songs')
    put "/#{id}", {title: 'yodle', description: 'joyful songs'}

    assert_equal 302, last_response.status

    idea = IdeaStore.find(id)
    assert_equal 'yodle', idea.title
    assert_equal 'joyful songs', idea.description
  end

  def test_delete_idea
    id = IdeaStore.save Idea.new('breathe', 'fresh air in the mountains')

    assert_equal 1, IdeaStore.count

    delete "/#{id}"

    assert_equal 302, last_response.status
    assert_equal 0, IdeaStore.count
  end

  def test_create_idea
    post '/', title: 'costume', description: 'scary vampire', tags: 'edward, bill'

    assert_equal 1, IdeaStore.count

    idea = IdeaStore.all.first
    assert_equal 'costume', idea.title
    assert_equal 'scary vampire', idea.description
    assert_equal ['edward', 'bill'], idea.tags
  end

  def test_show_by_certain_tag
    IdeaStore.save Idea.new "music", "Kayne West", "rap"
    IdeaStore.save Idea.new "bad music", "Nas", "rap"
    IdeaStore.save Idea.new "white people music", "John Mayer", "rock"

    get '/tags/rap'

    refute_equal 404, last_response.status
    assert_match /Kayne West/, last_response.body
    assert_match /Nas/, last_response.body
    refute_match /John Mayer/, last_response.body
  end

  def test_show_by_sorted_tags
    IdeaStore.save Idea.new "music", "Kayne West", "rap"
    IdeaStore.save Idea.new "bad music", "Nas", "rap"
    IdeaStore.save Idea.new "white people music", "John Mayer", "rock"

    get '/sorted_tags'

    refute_equal 404, last_response.status
    assert_match /Kayne West/, last_response.body
    assert_match /Nas/, last_response.body
    assert_match /John Mayer/, last_response.body
  end

  def test_show_by_sorted_hours
    idea1 = Idea.new "music", "Kayne West", "rap"
    IdeaStore.save idea1
    IdeaStore.save Idea.new "bad music", "Nas", "rap"
    IdeaStore.save Idea.new "white people music", "John Mayer", "rock"

    get '/sorted_by_hours'

    refute_equal 404, last_response.status
    assert last_response.body.include?("Ideas for Hour #{idea1.created_at.hour}"), "Titles aren't working"
    assert_match /Kayne West/, last_response.body
    assert_match /Nas/, last_response.body
    assert_match /John Mayer/, last_response.body
  end

end
