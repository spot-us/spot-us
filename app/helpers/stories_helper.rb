module StoriesHelper
  def supporters_count
    @story.pitch.supporters.size
  end
end