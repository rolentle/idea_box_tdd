require './lib/ideabox'

class IdeaboxApp < Sinatra::Base
  set :method_override, true
  set :root, "./lib/app"

  get '/' do
   erb :index, locals: {ideas: IdeaStore.all.sort.reverse}
  end

  post '/' do
    idea = Idea.new params[:title], params[:description], params[:tags]
    IdeaStore.save(idea)
    redirect '/'
  end

  get'/sorted_tags' do
    erb :sorted_tags, locals: { sorted_ideas: IdeaStore.sorted_by_tags}
  end

  get 'sorted_by_hours' do
    erb :sorted_by_hours, locals: { ideas_sorted_by_hour: IdeaStore.sorted_by_hour }
  end

  get '/:id' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :edit, locals: {idea: idea}
  end

  put '/:id' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.title = params[:title]
    idea.description =  params[:description]
    IdeaStore.save(idea)
    redirect '/'
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/like' do
    idea = IdeaStore.find(params[:id].to_i)
    idea.like!
    IdeaStore.save(idea)
    redirect '/'
  end

  get'/tags/:tag' do |tag|
    erb :tags, locals: {ideas: IdeaStore.find_all_by_tag(tag) }
  end

end
