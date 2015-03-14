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
    questions.each_with_object([]) do |q, memo|
      if should_filter? q
        repoint_questions! questions, q[:question_id], q[:default_next_question_id]
      else
        memo << q
      end
      memo
    end
  end

  def should_filter? q
    answered?(q) || blacklisted?(q) || question_sent_in_previous_response?(q)
  end

  def blacklisted? question
    Settings.blacklisted_questions.any? { |p| question[:question_id].include? p }
  end

  def question_sent_in_previous_response? question
    previous_questions.any? { |p| p.question_id == question[:question_id] }
  end

  def answered? question
    request_page[:data][question[:question_id].to_sym].present?
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
