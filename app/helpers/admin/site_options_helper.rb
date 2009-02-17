module Admin::SiteOptionsHelper
  def video_content
    SiteOption.for(:video_content)
  end

  def change_site_option(key)
    if current_user && current_user.admin?
      site_option = SiteOption.find_or_initialize_by_key(key)
      link_to "Edit #{key.to_s.humanize}", edit_admin_site_option_path(site_option), :rel => 'facebox'
    end
  end
end
