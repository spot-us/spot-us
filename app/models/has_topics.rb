module HasTopics
  def self.included(klass)
    klass.has_many(:topic_memberships, :foreign_key => :member_id, :as => "member")
    klass.has_many(:topics, :through => :topic_memberships)
  end
  
  def topics_params=(values)
    topics.clear
    values.each do |v| 
      topic = Topic.find(v.to_i) rescue nil
      topics << topic if topic
    end
  end
end