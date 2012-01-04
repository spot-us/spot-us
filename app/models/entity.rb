require "calais" if APP_CONFIG[:calais_key]

class Entity < ActiveRecord::Base

  LICENSE = APP_CONFIG[:calais_key]        # TO-DO: Make it abstract

  attr_accessor :request_body
  @@request_body = nil

  attr_accessor :entities
  @@entities = []

  attr_accessor :geographies
  @@geographies = []
  
  attr_accessor :coordinates
  @@coordinates = []

  def process?(text)
    self.request_body = text && !text.blank? ? Calais.process_document(:content => text, :license_id => LICENSE) : nil
  end

  def entities?(text=nil)
    self.entities = []
    self.process?(text) if text
    self.request_body.entities.each { |e| self.entities << {:type => e.type, :name => e.attributes["name"]} } if self.request_body
    return self.entities
  end
  
  def tags?(text)
    self.process?(text) unless self.request_body
    arr_e = self.entities?
    arr_e.map{ |a| a[:name] unless a[:type]=='URL' }.uniq.compact
  end

  def geographies?(text=nil)
    self.geographies = []
    self.process?(text) if text
    self.request_body.geographies.each { |g| self.geographies << {:name => g.name} } if self.request_body
    return self.geographies.uniq.compact
  end

  def coordinates?(text)
    self.coordinates = []
    self.process?(text) if text
    self.request_body.geographies.each { |g| self.coordinates << {:name => g.name, :longitude => g.attributes["longitude"], :latitude => g.attributes["latitude"]} } if self.request_body
    return self.coordinates
  end

  def language?(text)
    self.process?(text) if text
    return "Spanish" unless self.request_body
    return self.request_body.language 
  end

  def language_id?
    # TO-DO: add
  end

  def self.columns
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default,
    sql_type.to_s, null)
  end

  # Override the save method to prevent exceptions.
  def save(validate = true)
    validate ? valid? : true
  end

end
