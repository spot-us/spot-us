module Admin::SiteOptionsHelper
  def site_option_content_for(key)
    SiteOption.for(key)
  end

  def change_site_option(key)
    if current_user && current_user.admin?
      site_option = SiteOption.find_or_initialize_by_key(key)
      if site_option.new_record?
        site_option.value = 'Default value'
        site_option.save!
      end
      link_to "Edit #{key.to_s.humanize}", edit_admin_site_option_path(site_option), :rel => 'facebox'
    end
  end
end
