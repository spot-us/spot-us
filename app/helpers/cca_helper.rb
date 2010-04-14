module CcaHelper
  def survey_element(question, user, show_answer)
    text = ""
    case
    when question.question_type == "text_small"
      text << '<input type="text" name="answers[question_' << question.id.to_s << ']"'
      answer = question.answer_by_user(user)
      text << 'value="' << answer.answer << '"' if show_answer && answer
      text << ' />'
    when question.question_type == "text_big"
      text << '<textarea name="answers[question_' << question.id.to_s << ']">'
      answer = question.answer_by_user(user)
      text << answer.answer if show_answer && answer
      text << '</textarea>'
    when question.question_type == "radio"
      items = question.question_data.split("||")
      items.each do |item|
        text << '<input type="radio" name="answers[question_' << question.id.to_s << ']"'
        answer = question.answer_by_user(user)
        text << 'value="' << item << '"'
        text << ' checked' if show_answer && answer && answer.answer == item
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
        text << '<fieldset><legend>'
        text << question.section 
        text << '</legend>'
      end
    end
    text
  end
  
  def end_survey_sections
      '</fieldset>' if !@current_section.blank?
  end
      
end
