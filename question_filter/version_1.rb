class QuestionsFilter

  def self.filter request_page, reactor_data
    questions = request_page[:questions]
    questions = filter_previous_questions questions, reactor_data[:request][:id]
    questions = filter_blacklisted_questions questions
    questions = filter_answered_questions questions, request_page
    questions
  end

  def self.filter_answered_questions questions, request_page
    questions.reduce([]) do |memo, q|
      answer = request_page[:data][q[:question_id].to_sym]
      if answer.present?
        repoint_questions! memo, q[:question_id], q[:default_next_question_id]
      else
        memo << q
      end
      memo
    end
  end

  def self.filter_previous_questions questions, request_id
    previous_questions = RequestQuestion.where(request_id: request_id).all
    questions.reduce([]) do |memo, q|
      if previous_questions.any? { |p| p.question_id == q[:question_id] }
        repoint_questions! memo, q[:question_id], q[:default_next_question_id]
      else
        memo << q
      end
      memo
    end
  end

  def self.filter_blacklisted_questions questions
    questions.reduce([]) do |memo, q|
      if Settings.blacklisted_questions.any? { |p| q[:question_id].include? p }
        repoint_questions! memo, q[:question_id], q[:default_next_question_id]
      else
        memo << q
      end
      memo
    end
  end

  def self.repoint_questions! questions, old_id, new_id
    questions.each do |q|
      if q[:default_next_question_id] == old_id
        q[:default_next_question_id] = new_id
      end
      choices = q.fetch(:choices, [])
      choices.each do |choice|
        choice[:next_question_id] = new_id if choice[:next_question_id] == old_id
      end
    end
    questions
  end
end
