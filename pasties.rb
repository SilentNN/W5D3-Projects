reset
load 'questions_database.rb'
QuestionFollow.followers_for_question_id(1)
QuestionFollow.followers_for_question_id(2)
QuestionFollow.followers_for_question_id(3)










reply = Reply.find_by_id(1)
reply.parent_reply



tony = User.find_by_name('Tony', 'Baloney')
tony.authored_questions
