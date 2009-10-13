require File.join(File.dirname(__FILE__), 'abstract_unit')

class AddColumnAfterTest < Test::Unit::TestCase
  def test_add_column_after
    ActiveRecord::Base.connection.create_table(:add_column_after_test) do |t|
      t.column :column_one, :string
      t.column :column_three, :string
    end
    
    assert_nothing_raised { ActiveRecord::Base.connection.add_column :add_column_after_test, :column_two, :string, :after => 'column_one' }
    columns = ActiveRecord::Base.connection.columns('add_column_after_test').collect { |c| c.name }
    assert_equal columns.index('column_one'), columns.index('column_two')-1
  ensure
    ActiveRecord::Base.connection.drop_table(:add_column_after_test) rescue nil
  end
end
