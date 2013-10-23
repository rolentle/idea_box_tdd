class Idea
  include Comparable
  attr_accessor :title, :description, :rank, :id, :tags

  def initialize(title,description, tags="no tags")
    @title = title
    @description = description
    @rank ||= 0
    @tags = tags.gsub(", ", ",").split ","
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    rank <=> other.rank
  end

end
