require 'sqlite3'
require 'singleton'

class QuestionsDataBase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class User
  attr_accessor :fname, :lname
  attr_reader :id
  def self.all
    data = QuestionsDataBase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    user = QuestionsDataBase.instance.execute(<<-SQL, id)
    SELECT * FROM users WHERE id = ?
    SQL
    return nil if user.empty?
    User.new(user.first)
  end

  def self.find_by_name(name)
    user = QuestionsDataBase.instance.execute(<<-SQL, name)
    SELECT * FROM users WHERE fname = ? OR lname = ?
    SQL
    return nil if user.empty?
    User.new(user.first)
  end

  def authored_replies
    Replies.find_by_user_id(@id)
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end
end

class Question

  attr_accessor :title, :body, :author_id
  attr_reader :id

  def self.all
    data = QuestionsDataBase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDataBase.instance.execute(<<-SQL, id)
    SELECT * FROM questions WHERE id = ?
    SQL
    return nil if question.empty?
    Question.new(question.first)
  end

  def self.find_by_author_id(author_id)
    author_id = QuestionsDataBase.instance.execute(<<-SQL, author_id)
      SELECT * FROM questions WHERE author_id = ?
    SQL
    return nil if author_id.empty?
    Question.new(author_id.first)
  end

  def self.most_followed_questions(n)
    data = QuestionsDataBase.instance.execute(<<-SQL, n)
    SELECT *
    FROM questions JOIN question_follows
    ON questions.id = question_follows.question_id
    GROUP BY questions.id HAVING COUNT(questions.id)
    ORDER BY questions.id desc  
    LIMIT ?
    SQL
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @author_id = options['author_id']
  end

end

class Follow

  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.all
    data = QuestionsDataBase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| Follow.new(datum) }
  end

  def self.find_by_id(id)
    follow = QuestionsDataBase.instance.execute(<<-SQL, id)
    SELECT * FROM question_follows WHERE id = ?
    SQL
    return nil if follow.empty?
    Follow.new(follow.first)
  end

  def self.question_follow(question_id)
    result = QuestionsDataBase.instance.execute(<<-SQL, question_id)
    SELECT * FROM users JOIN question_follows ON (question_follows.user_id = users.id)
    WHERE question_follows.question_id = ?
    SQL
    return nil if result.empty?
    result.map { |info| Question.new(info) }
  end

  def self.followed_questions_for_user_id(user_id)
    result = QuestionsDataBase.instance.execute(<<-SQL, user_id)
    SELECT * FROM question_follows JOIN questions ON (question_follows.user_id = questions.author_id)
    WHERE question_follows.user_id = ?
    SQL
    return nil if result.empty?
    result.map { |info| Question.new(info) }
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end

class Replies

  attr_accessor :parent_reply_id, :question_id, :author_id, :body
  attr_reader :id

  def self.all
    data = QuestionsDataBase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Replies.new(datum) }
  end

  def self.find_by_id(id)
    reply = QuestionsDataBase.instance.execute(<<-SQL, id)
    SELECT * FROM replies WHERE id = ?
    SQL
    return nil if reply.empty?
    Replies.new(reply.first)
  end

  def self.find_by_user_id(user_id)
    user_id = QuestionsDataBase.instance.execute(<<-SQL, user_id)
    SELECT * FROM replies WHERE author_id = ?
    SQL
    return nil if user_id.empty?
    Replies.new(user_id.first)
  end

  def self.find_by_parent_id(parent_id)
    parent_id = QuestionsDataBase.instance.execute(<<-SQL, parent_id)
    SELECT * FROM replies WHERE parent_reply_id = ?
    SQL
    return nil if parent_id.empty?
    Replies.new(parent_id.first)
  end

  def self.find_by_question_id(question_id)
    question_id = QuestionsDataBase.instance.execute(<<-SQL, question_id)
    SELECT * FROM replies WHERE question_id = ?
    SQL
    return nil if user_id.empty?
    Replies.new(user_id.first)
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @author_id = options['author_id']
    @body = options['body']
  end

  def author
    User.find_by_id(@author_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    Replies.find_by_id(@parent_reply_id)
  end

  def child_replies
    Replies.find_by_parent_id(@id)
  end

end


class Likes

  attr_accessor :user_id, :question_id
  attr_reader :id

  def self.all
    data = QuestionsDataBase.instance.execute("SELECT * FROM question_likes")
    data.map { |datum| Likes.new(datum) }
  end

  def self.find_by_id(id)
    likes = QuestionsDataBase.instance.execute(<<-SQL, id)
    SELECT * FROM question_likes WHERE id = ?
    SQL
    return nil if likes.empty?
    Likes.new(reply.first)
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end
end
