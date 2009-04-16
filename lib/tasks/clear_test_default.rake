unless File.exist?(File.join(Rails.root, 'test', 'test_helper.rb'))
  Rake::Task[:default].clear
end
