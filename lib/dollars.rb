class ActiveRecord::Base
  def self.has_dollar_field(field_name)
    field_name = field_name.to_sym
    define_method field_name do
      self[:"#{field_name}_in_cents"].to_dollars
    end

    define_method :"#{field_name}=" do |dollars|
      normalized_dollars = dollars.to_s =~ /[^\d\.]/ ? dollars.to_s.gsub(/[^\d\.]/, "") : dollars
      self[:"#{field_name}_in_cents"] = normalized_dollars.to_cents
    end
  end
end

class Fixnum
  def to_dollars
    (self / 100.0).to_s
  end

  def to_cents
    (self * 100).to_i
  end
end

class Float
  def to_dollars
    (self / 100.0).to_s
  end

  def to_cents
    (self * 100).to_i
  end
end

class String
  def to_cents
    self.to_f.to_cents
  end

  def to_dollars
    self.to_i.to_dollars
  end
end

class NilClass
  def to_cents
    nil
  end

  def to_dollars
    nil
  end
end
