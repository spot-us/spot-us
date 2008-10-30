# Helpers to sort tables using clickable column headers.
#
# Author:  Stuart Rackham <srackham@methods.co.nz>, March 2005.
# License: This source code is released under the MIT license.
#
# - Consecutive clicks toggle the column's sort order.
# - Sort state is maintained by a session hash entry.
# - Icon image identifies sort column and state.
# - Typically used in conjunction with the Pagination module.
#
# Example code snippets:
#
# Controller:
#
#   helper :sort
#   include SortHelper
#
#   def list
#     sort_init 'last_name'
#     sort_update
#     @items = Contact.find(:all, :conditions => sort_clause)
#   end
#
# Controller with paginator:
#
#   helper :sort
#   include SortHelper
#
#   def list
#     sort_init 'last_name'
#     sort_update
#     @contact_pages, @items = paginate(:contacts,
#       :order_by => sort_clause,
#       :per_page => 10)
#   end
#
# View (table header in list.rhtml):
#
#   <thead>
#     <tr>
#       <%= sort_header_tag('id', :title => 'Sort by contact ID') %>
#       <%= sort_header_tag('last_name', :text => 'Name') %>
#       <%= sort_header_tag('phone') %>
#       <%= sort_header_tag('address', :width => 200) %>
#     </tr>
#   </thead>
#
# - The ascending and descending sort icon images are sort_asc.png and
#   sort_desc.png and reside in the application's images directory.
# - Introduces instance variables: @sort_name, @sort_default.
# - Introduces params :sort_key and :sort_order.
#
# History
# -------
# 2007-05-31: Version 1.0.3 (patch submitted by Chris Parker)
#             - If :title is specified, then that is set as the <th> text
#             - Add the ability to add optional :param values
# 2006-04-04: Version 1.0.2
#             - Tidied up examples.
#             - Changed older @params and @session style to params and sessions.
# 2006-01-19: Version 1.0.1
#             - sort_init() accepts options hash.
#             - sort_init() :icons_dir option added.
# 2005-03-26: Version 1.0.0
#
module SortHelper


  # Initializes the default sort column (default_key) with the following
  # options:
  #
  # - :default_order -- the default sort order 'asc' or 'desc'. Defaults to
  #   'asc'.
  # - :name -- the name of the session hash entry that stores the sort state.
  #   Defaults to '<controller_name>_sort'.
  # - :icons_dir -- directory with sort direction icons. Defaults to
  #   /images
  #
  def sort_init(default_key, options={})
    options = { :default_order => 'asc',
                :name => params[:controller] + '_sort',
                :icons_dir => '/images',
              }.merge(options)
    @sort_name = options[:name]
    @sort_default = {:key => default_key, :order => options[:default_order]}
    @icons_dir = options[:icons_dir]
  end

  # Updates the sort state. Call this in the controller prior to calling
  # sort_clause.
  #
  def sort_update()
    if params[:sort_key]
      sort = {:key => params[:sort_key], :order => params[:sort_order]}
    elsif session[@sort_name]
      sort = session[@sort_name]   # Previous sort.
    else
      sort = @sort_default
    end
    session[@sort_name] = sort
  end

  # Returns an SQL sort clause corresponding to the current sort state.
  # Use this to sort the controller's table items collection.
  #
  def sort_clause()
    result = session[@sort_name][:key] + ' ' + session[@sort_name][:order]
    result if result =~ /^[\w_]+ (asc|desc)$/i  # Validate sort.
  end

  # Returns a link which sorts by the named column.
  #
  # - column is the name of an attribute in the sorted record collection.
  # - The optional text explicitly specifies the displayed link text.
  # - A sort icon image is positioned to the right of the sort link.
  #
  def sort_link(column, text=nil, options=nil)
    key, order = session[@sort_name][:key], session[@sort_name][:order]
    if key == column
      if order.downcase == 'asc'
        icon, order = 'sort_asc', 'desc'
      else
        icon, order = 'sort_desc', 'asc'
      end
    else
      icon, order = nil, 'asc'
    end
    text = Inflector::titleize(column) unless text
    params = {:params => {:sort_key => column, :sort_order => order } }
    params = params.merge(options[:params]) if options[:params]
    link_to(text, params) 
  end

  # Returns a table header <th> tag with a sort link for the named column
  # attribute.
  #
  # Options:
  #   :text     The displayed link name (defaults to titleized column name).
  #   :title       The tag's 'title' attribute (defaults to 'Sort by :text').
  #
  # Other options hash entries generate additional table header tag attributes.
  #
  # Example:
  #
  #   <%= sort_header_tag('id', :title => 'Sort by contact ID', :width => 40) %>
  #
  # Renders:
  #
  #   <th title="Sort by contact ID" width="40">
  #     <a href="/contact/list?sort_order=desc&amp;sort_key=id">Id</a>
  #     &nbsp;&nbsp;<img alt="Sort_asc" src="/images/sort_asc.png" />
  #   </th>
  #
  def sort_header_tag(column, options = {})
    text = options.delete(:text) || Inflector::titleize(column.humanize)
    options[:title]= "Sort by #{text}" unless options[:title]
    text = options[:title] || options.delete(:text) || Inflector::titleize(column.humanize)
    content_tag('th', sort_link(column, text, options), options)
  end

  private

    # Return n non-breaking spaces.
    def nbsp(n)
      '&nbsp;' * n
    end

end
