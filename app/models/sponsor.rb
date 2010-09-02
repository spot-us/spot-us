class Sponsor < User
  
  def full_name
    return organization_name if organization_name && !organization_name.empty?
    [first_name, last_name].join(' ')
  end
  
end