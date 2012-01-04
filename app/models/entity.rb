require "calais" if APP_CONFIG[:calais_key]

class Entity < ActiveRecord::Base

  LICENSE = APP_CONFIG[:calais_key]        # TO-DO: Make it abstract

  belongs_to :entitable, :polymorphic => true
  serialize :request_body
  
  attr_accessor :entities
  @@entities = []

  attr_accessor :geographies
  @@geographies = []
  
  attr_accessor :coordinates
  @@coordinates = []

  def process?(text)
    self.request_body = text && !text.blank? ? Calais.process_document(:content => text, :license_id => LICENSE) : nil
    self.save
  end

  def entities?
    self.entities = []
    self.request_body.entities.each { |e| self.entities << {:type => e.type, :name => e.attributes["name"]} } if self.request_body
    return self.entities
  end
  
  def tags?(text)
    arr_e = self.entities?
    arr_e.map{ |a| a[:name] unless a[:type]=='URL' }.uniq.compact
  end

  def geographies?
    self.geographies = []
    self.request_body.geographies.each { |g| self.geographies << {:name => g.name} if g.attributes["longitude"] && g.attributes["latitude"] } if self.request_body
    return self.geographies.uniq.compact
  end

  def coordinates?
    self.coordinates = []
    self.request_body.geographies.each { |g| self.coordinates << {:name => g.name, :longitude => g.attributes["longitude"], :latitude => g.attributes["latitude"]} if g.attributes["longitude"] && g.attributes["latitude"] } if self.request_body
    return self.coordinates
  end

  def language?
    return "Spanish" unless self.request_body
    return self.request_body.language 
  end

  def language_id?
    # TO-DO: add
  end

end
