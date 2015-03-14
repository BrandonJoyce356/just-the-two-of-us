class QuestionsFilter

  def initialize request_page, reactor_data
    @request_page = request_page
    @reactor_data = reactor_data
  end

  def self.filter request_page, reactor_data
    new(request_page, reactor_data).filter
  end

  private

  attr_reader :request_page, :reactor_data

  def request_id
    reactor_data[:request][:id]
  end

  def questions
    request_page[:questions]
  end

  def previous_questions
    RequestQuestion.where(request_id: request_id).all
  end

  def filter
    result = questions
    result = filter_previous_questions result, request_id
    result = filter_blacklisted_questions result
    result = filter_answered_questions result
  end

  def filter_answered_questions questions
    questions.each_with_object([]) do |q, memo|
      answer = request_page[:data][q[:question_id].to_sym]
      if answer.present?
        repoint_questions! memo, q[:question_id], q[:default_next_question_id]
      else
        memo << q
      end
      memo
    end
  end

  def filter_previous_questions questions, request_id
    questions.each_with_object([]) do |q, memo|
      if previous_questions.any? { |p| p.question_id == q[:question_id] }
        repoint_questions! memo, q[:question_id], q[:default_next_question_id]
      else
        memo << q
      end
      memo
    end
  end

  def filter_blacklisted_questions questions
    questions.each_with_object([]) do |q, memo|
      if Settings.blacklisted_questions.any? { |p| q[:question_id].include? p }
        repoint_questions! memo, q[:question_id], q[:default_next_question_id]
      else
        memo << q
      end
      memo
    end
  end

  def repoint_questions! questions, old_id, new_id
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
