class Idea
  include Comparable
  attr_accessor :title, :description, :rank, :id, :tags, :created_at, :updated_at

  def initialize(title,description, tags="no tags")
    @title = title
    @description = description
    @rank ||= 0
    @tags = tags.gsub(", ", ",").split ","
    @created_at ||= DateTime.now
    @updated_at = DateTime.now
  end

  def like!
    @rank += 1
  end

  def <=>(other)
    rank <=> other.rank
  end

end
