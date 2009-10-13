require 'add_column_after'

class ActiveRecord::ConnectionAdapters::MysqlAdapter
  include BrionesAndCo::ActiveRecord::ConnectionAdapters::AddColumnAfter
end