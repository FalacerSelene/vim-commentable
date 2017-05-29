StartTest simple_join many_comments

for b:case in range(1, 2)
	NextTest
	NormalStyle
	UseCase b:case
	Assert b:case_firstline . ',' . b:case_lastline . 'CommentableCreate'
endfor

EndTest
