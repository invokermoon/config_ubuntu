hi u_student ctermbg=red guibg=white
hi u_subject ctermbg=lightblue guibg=white
hi u_mark_fail ctermbg=red guibg=white
hi u_mark_a ctermbg=darkcyan guibg=white
" 上面的命令定义了不同的组及其对应的颜色
" 现在我们要用match告诉Vim怎么分辨不同的组，
" 我们要用到一些的正则表达式

"行头开始至第一个空白字符
syn match u_student /^\S*/
syn match u_subject /数学/
syn match u_mark_fail /\s[1-5]\=.$/
syn match u_mark_a /\s100\|\s9.$/

