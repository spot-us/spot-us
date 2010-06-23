class AddPitchIdToCcaAnswers < ActiveRecord::Migration
  def self.up
	add_column :cca_answers, :pitch_id, :integer
  end

  def self.down
	remove_column :cca_answers, :pitch_id
  end
end
