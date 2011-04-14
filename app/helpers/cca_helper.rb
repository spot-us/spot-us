module CcaHelper
	def survey_element(question, user, show_answer, default_answer=false, highlight=false)
		text = ""
		case
		when question.question_type == "text_small"
			text << '<input type="text" name="answers[question_' << question.id.to_s << ']"'
			answer = question.answer_by_user(user, default_answer)
			text << 'value="' << answer.answer << '"' if show_answer && answer
			text << ' />'
		when question.question_type == "text_big"
			text << '<textarea name="answers[question_' << question.id.to_s << ']">'
			answer = question.answer_by_user(user, default_answer)
			text << answer.answer if show_answer && answer
			text << '</textarea>'
		when question.question_type == "radio"
			items = question.question_data.split("\n")
			items.each do |item|
				item = item.strip
				text << '<input type="radio" name="answers[question_' << question.id.to_s << ']"'
				answer = question.answer_by_user(user, default_answer)
				text << 'value="' << item << '"'
				text << ' checked' if show_answer && answer && answer.answer == item
				text << '> '
				text << item
				text << "<br/>"
			end
		when question.question_type == "radio_horizontal"
			items = question.question_data.split("\n")
			text << "<ul class=\"radioHorizontal\">"
			items.each do |item|
				item = item.strip
				  text << "<li>"
            text << item
            text << "<br/>"
    				text << '<input type="radio" name="answers[question_' << question.id.to_s << ']"'
    				answer = question.answer_by_user(user, default_answer)
    				text << 'value="' << item << '"'
    				text << ' checked' if show_answer && answer && answer.answer == item
    				text << '> '
  				text << "</li>"
			end
			text << "</ul>"
		when question.question_type == "checkbox"
			items = question.question_data.split("\n")
			items.each do |item|
				item = item.strip
				text << '<input type="checkbox" name="answers[question_' << question.id.to_s << '][]"'
				answer = question.answer_by_user(user, default_answer)
				text << 'value="' << item << '"'
				text << ' checked="yes"' if show_answer && answer && answer.answer.split("\n").include?(item)
				text << '> '
				text << item
				text << "<br/>"
			end
		else

		end
		text
	end
  
  def is_required(bool)
    ' <span class="deep-red">*</span>' if bool
  end
  
  def survey_section(question, index)
    text = ""
    if @current_section != question.section
      @current_section = question.section
      text << '</fieldset>' if index > 0
      unless question.section.blank?
        text << '<fieldset class="surveySection"><legend>'
        text << question.section 
        text << '</legend>'
      end
    end
    text
  end
  
    def end_survey_sections
      '</fieldset>' if !@current_section.blank?
    end

    def section_links(sections)
      section_links = []
  		sections.each do |section|
  			section_links << "<a href=\"\" onclick=\"setSection('#{section}');return false;\">#{section}</a>"
  		end
  		section_links.compact.join(' | ')
    end
end
