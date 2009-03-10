ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :date => '%B %e, %Y',
  :date_time  => "%m/%d/%Y %I:%M%p",
  :long_date => '%A, %B %e, %Y',
  :super_short => '%m/%d/%y'
)

