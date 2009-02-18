ActiveRecord::Base.class_eval { include AttributeFu::Associations }
ActionView::Helpers::FormBuilder.class_eval { include AttributeFu::AssociatedFormHelper }