class IdeaStore

  def self.save(idea)
    idea.id ||= next_id
    all[idea.id] = idea
    idea.id
  end

  def self.count
    all.length
  end

  def self.find(id)
    all[id]
  end

  def self.next_id
    all.size
  end

  def self.delete_all
    @all = []
  end

  def self.all
    @all ||= []
  end

  def self.delete(idea)
    all.delete_at(idea)
  end

  def self.find_by_title(title)
    all.find { |idea| idea.title == title }
  end

  def self.find_all_by_tag(tag)
    tag = tag.downcase
    all.select { |idea| idea.tags.include?(tag) }
  end
end
