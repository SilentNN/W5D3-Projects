require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
    include Singleton
    def initialize 
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end

class Question
    attr_accessor :id, :title, :body, :users_id

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM questions')
        data.map { |datum| Question.new(datum) }
    end

    def self.find_by_id(qid)
        # Question.all.each { |question| return question if question.id == qid }

        q = QuestionsDatabase.instance.execute(<<-SQL, qid)
            SELECT 
                * 
            FROM 
                questions 
            WHERE 
                id = ?;
        SQL
        Question.new(*q)
    end

    def initialize(hash)
        @id = hash['id']
        @title = hash['title']
        @body = hash['body']
        @users_id = hash['users_id']
    end
    
    def self.find_by_author_id(aid)
        # output = []
        # Question.all.each { |question| output << question if question.users_id == aid }
        # output
        q = QuestionsDatabase.instance.execute(<<-SQL, aid)
            SELECT 
                * 
            FROM 
                questions 
            WHERE 
                users_id = ?;
        SQL
        Question.new(*q)
    end

    def author
        User.find_by_id(@users_id)
    end

    def replies
        # output = []
        # Reply.all.each { |reply| output << reply if reply.questions_id == @id }
        # output
        q = QuestionsDatabase.instance.execute(<<-SQL, self.id)
            SELECT 
                * 
            FROM 
                replies 
            WHERE 
                questions_id = ?;
        SQL
        q.map { |datum| Reply.new(datum)}
        # Question.new(*q)
    end
end


class User 
    attr_accessor :fname, :lname, :id

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM users')
        data.map { |datum| User.new(datum) }
    end

    def self.find_by_id(uid)
        # User.all.each { |user| return user if user.id == uid }
        q = QuestionsDatabase.instance.execute(<<-SQL, uid)
            SELECT 
                * 
            FROM 
                users 
            WHERE 
                users_id = ?;
        SQL
        User.new(*q)
    end

    def self.find_by_name(first, last)
        # User.all.each { |user| return user if user.fname == first && user.lname == last }
        q = QuestionsDatabase.instance.execute(<<-SQL, first, last)
            SELECT 
                * 
            FROM 
                users 
            WHERE 
                fname = ? AND lname = ?;
        SQL
        User.new(*q)
    end

    def authored_questions
        # output = []
        # Question.all.each { |q| output << q if q.users_id == @id}
        # output
        q = QuestionsDatabase.instance.execute(<<-SQL, self.id)
            SELECT 
                * 
            FROM 
                questions 
            WHERE 
                users_id = ?;
        SQL
        # Question.new(*q)
        q.map { |datum| Question.new(datum) }
    end

    def authored_replies
        # output = []
        # Reply.all.each { |reply| output << reply if reply.users_id == @id }
        # output

        q = QuestionsDatabase.instance.execute(<<-SQL, self.id)
            SELECT 
                * 
            FROM 
                replies 
            WHERE 
                users_id = ?;
        SQL
        q.map { |datum| Reply.new(datum) }
    end

    def initialize(options)
        @fname = options['fname']
        @lname = options['lname']
        @id = options['id']
    end
end

class Reply
    attr_accessor :id, :body, :questions_id, :users_id, :parent_id

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM replies')
        data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_id(rid)
        # Reply.all.each { |reply| return reply if reply.id == rid }

        q = QuestionsDatabase.instance.execute(<<-SQL, rid)
            SELECT 
                * 
            FROM 
                replies 
            WHERE 
                id = ?;
        SQL
        Reply.new(*q)
    end
    
    def self.find_by_user_id(uid)
        # output = []
        # Reply.all.each { |reply| output << reply if reply.users_id == uid}
        # output

        q = QuestionsDatabase.instance.execute(<<-SQL, uid)
            SELECT 
                * 
            FROM 
                replies 
            WHERE 
                users_id = ?;
        SQL
        q.map { |datum| Reply.new(datum) }
    end

    def self.find_by_questions_id(qid)
        # output = []
        # Reply.all.each { |reply| output << reply if reply.questions_id == qid }
        # output

        q = QuestionsDatabase.instance.execute(<<-SQL, qid)
            SELECT 
                * 
            FROM 
                replies 
            WHERE 
                questions_id = ?;
        SQL
        q.map { |datum| Reply.new(datum) }
    end

    def initialize(options)
        @id = options['id']
        @body = options['body']
        @questions_id = options['questions_id']
        @users_id = options['users_id']
        @parent_id = options['parent_id']
    end

    def author
        User.find_by_id(@users_id)
    end

    def question
        Question.find_by_id(@questions_id)
    end

    def parent_reply
        return [] unless parent_id
        Reply.find_by_id(@parent_id)
    end

    def child_replies
        # output = []
        # Reply.all.each { |reply| output << reply if reply.parent_id == @id }
        # output

        q = QuestionsDatabase.instance.execute(<<-SQL, self.id)
            SELECT 
                * 
            FROM 
                replies 
            WHERE 
                parent_id = ?;
        SQL
        q.map { |datum| Reply.new(datum) }
    end
end

class QuestionFollow

    def self.followers_for_question_id(qid)
        # output = []
        # QuestionFollow.all.each { |qfollow| output << qfollow.users_id if qfollow.questions_id == qid}
        # output.map {|uid| User.find_by_id(uid)}

        q = QuestionsDatabase.instance.execute(<<-SQL, qid)
            SELECT 
                *
            FROM 
                question_follows
            JOIN
                users ON question_follows.users_id = users.id
            WHERE 
                questions_id = ?;
        SQL
        q.map { |datum| User.new(datum) }
    end

    def self.followed_questions_for_user_id(uid)
        q = QuestionsDatabase.instance.execute(<<-SQL, uid)
            SELECT 
                *
            FROM 
                question_follows
            JOIN
                questions ON question_follows.questions_id = questions.id
            WHERE 
                users_id = ?;
        SQL
        q.map { |datum| Question.new(datum) }
    end

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM question_follows')
        data.map { |datum| QuestionFollow.new(datum) }
    end

    def initialize(options)
        
    end
end
