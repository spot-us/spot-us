module HasTopics
  def self.included(klass)
    klass.has_many(:topic_memberships, :foreign_key => :member_id)
    klass.has_many(:topics, :through => :topic_memberships)
  end
  
  def topics_params=(values)
    values.each do |v| 
      topic = Topic.find(v.to_i) rescue nil
      topics << topic if topic && !topics.include?(topic)
    end
  end
end