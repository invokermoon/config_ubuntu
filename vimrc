""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Bundler
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible               " be iMproved
filetype off                   " required!

"git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
    "let path = '~/some/path/here'
    "call vundle#rc(path)

" let Vundle manage Vundle required!
Plugin 'VundleVim/Vundle.vim'

" original repos on github
" github上的用户写的插件，使用这种用户名+repo名称的方式
"Bundle 'tpope/vim-fugitive'
"Bundle 'rstacruz/sparkup', {'rtp': 'vim/'}
"Bundle 'tpope/vim-rails.git'

" vimscripts的repo使用下面的格式，直接是插件名称
"" vim-scripts repos
"Bundle 'L9'
"Bundle 'FuzzyFinder'

"" non github repos
"Bundle 'git://git.wincent.com/command-t.git'
"" ...
"Plugin 'vim-airline/vim-airline'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'majutsushi/tagbar'
Plugin 'vim-scripts/gtags.vim'

call vundle#end()

filetype plugin indent on     " required!
"
" Brief help  -- 此处后面都是vundle的使用命令
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set report=0
set noswapfile
set autowrite
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""tab config"{{{
"对于已保存的文件，可以使用下面的方法进行空格和TAB的替换：
"TAB替换为空格：
":set ts=4
":set expandtab
":%retab!
"
"空格替换为TAB：
":set ts=4
":set noexpandtab
":%retab!
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set tabstop=4
set shiftwidth=4
"set noexpandtab
set expandtab
set smarttab
"将tab替换为空格
"nmap tt :%s/\t/ /g<CR>"}}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"vim 窗口大小
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set lines=50"{{{
"set columns=140
set background=dark
set nu  "set number""}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"高亮颜色"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on
"set cul "高亮光标所在lines
"set cuc "高亮当前colums
"set cursorline " 突出显示当前行
autocmd InsertLeave * se nocul " 取消浅色高亮当前行
autocmd InsertEnter * se cul " 用浅色高亮当前行
"搜索逐字符高亮
set hlsearch
set incsearch"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"一般设置
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set shortmess=atI " 启动的时候不显示那个援助乌干达儿童的提示"{{{
set go= " 不要图形按钮，工具栏
set showcmd " 输入的命令显示出来，看的清楚些
set history=1000
"set mouse=a
"set mouse=v
"set selection=exclusive
"set selectmode=mouse,key
" 在被分割的窗口间显示空白，便于阅读
set fillchars=vert:\ ,stl:\ ,stlnc:\
set magic
set ignorecase
"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"颜色主题
"终端类型       前景色          背景色          注释
"term           -               -               黑白终端
"cterm          ctermfg         ctermgb         彩色终端
"gui            guifg           guibg           图形介面
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"color desert256 " 设置背景主题
"color ron " 设置背景主题
"color torte " 设置背景主题
""""""""""""""""""""""""""""""""""GUI颜色配置""""""""""""""""""""""""""""""""""""""""""""""""""""""""""{{{
if has("gui_running")           " 如果是图形界面
    set guioptions=m        " 关闭菜单栏
    set guioptions=t        " 关闭工具栏
"   set guioptions=L        " 启动左边的滚动条
"   set guioptions+=r       " 启动右边的滚动条
"   set guioptions+=b       " 启动下边的滚动条
    set clipboard+=unnamed      " 共享剪贴板
    if has("win32")
           colorscheme torte    " torte配色方案
           set guifont=Consolas:h11 " 字体和大小
    endif
endif   "}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"字体编码"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set guifont=Courier\ 8 " 设置字体
"set guifont=Courier_New:h6:cANSI   " 设置字体
"set guifont=Monospace\ 8  "设置字体大小
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,GB18030,cp936,big5,euc-jp,euc-kr,latin1
set nocompatible "去掉讨厌的有关vi一致性模式，避免以前版本的一些bug和局限
" 显示中文帮助
set helplang=cn
"""""""解决consle输出乱码
"language messages zh_CN.utf-8
"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"file type 配置"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype on
filetype plugin on
filetype indent on
" 以上三个命令就是开启file检测功能，可以autocmd等一系列操作了"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"智能匹配，补全"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set showmatch   "在输入括号时光标会短暂地跳到与之相匹配的括号处

"现在补全功能就狂强了。需要补全的时候ctrl-x
"ctrl-o连着按，就会跳出一个候选菜单。啊，以前不知道，还到处搜索vim补全插件。现在好了。非常齐全了。呼，赶快开始享受编程"
set nocp
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 进行Taglist的设置<Begin>"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
:nmap <silent> <F9> <ESC>:Tlist<RETURN>

"tagbar setting
":nmap <F8> :TagbarToggle<CR>
"map <F9> :TlistToggle<CR>
"map <F9> :silent! Tlist<CR>             "按下F3就可以呼出了
"let Tlist_Ctags_Cmd='/usr/bin/ctags'    "因为我们放在环境变量里，所以可以直接执行
let Tlist_Use_Right_Window=1            "让窗口显示在右边，0的话就是显示在左边
let Tlist_Show_One_File=1               "让taglist可以同时展示多个文件的函数列表
"let Tlist_File_Fold_Auto_Close=1        "非当前文件，函数列表折叠隐藏
let Tlist_Exit_OnlyWindow=1             "当taglist是最后一个分割窗口时，自动推出vim
let Tlist_Process_File_Always=1         "是否一直处理tags.1:处理;0:不处理
"let Tlist_Inc_Winwidth=0                "不是一直实时更新tags，因为没有必要"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"#中括号 大括号 小括号 自动补全"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
":inoremap ( ()<ESC>i
":inoremap ) <c-r>=ClosePair(')')<CR>
":inoremap { {}<ESC>i
":inoremap } <c-r>=ClosePair('}')<CR>
":inoremap [ []<ESC>i
":inoremap ] <c-r>=ClosePair(']')<CR>
":inoremap < <><ESC>i
":inoremap > <c-r>=ClosePair('>')<CR>
"function ClosePair(char)
"    if getline('.')[col('.') - 1] == a:char
"        return "\<Right>"
"    else
"        return a:char
"    endif
"endfunction"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"状态栏配置"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"[master]set ruler       " 标尺，用于显示光标位置的行号和列号，逗号分隔。每个窗口都有自己的标尺。如果窗口有状态行，标尺在那里显示。否则，它显示在屏幕的最后一行上。
"[master]set laststatus=2 " 启动显示状态行(1),总是显示状态行(2)
"[master]set scrolloff=3 " 光标移动到buffer的顶部和底部时保持3行距离
" default the statusline to green when entering Vim
"[Master]hi StatusLine ctermfg=0 ctermbg=white
"set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [POS=%l,%v][%p%%] "状态行显示的内容
"set statusline=%2*%n%m%r%h%w%*\ %F\ %1*[%2*%{&ff}:%{&fenc!=''?&fenc:&enc}%1*]\ [%2*%Y%1*]\ [ROW=%2*%03l%1*/%3*%L(%p%%)%1*]\
"[master]set statusline=%2*%n%m%r%h%w%*\ %F\ %1*[%2*%{&ff}:%{&fenc!=''?&fenc:&enc}%1*]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%v,%2*%03l%1*/%3*%L(%p%%)%1*]

"[master]function! InsertStatuslineColor(mode)
"[master]    if a:mode == 'i'
"[master]        hi statusline guibg=magenta term=reverse ctermbg=red gui=undercurl
"[master]    elseif a:mode == 'r'
"[master]        hi statusline guibg=white term=reverse ctermfg=0 ctermbg=white gui=bold,reverse
"[master]    else
"[master]        hi statusline guibg=blue term=reverse ctermfg=0 ctermbg=blue gui=bold,reverse
"[master]    endif
"[master]endfunction
"[master]au InsertEnter * call InsertStatuslineColor(v:insertmode)
"[master]au InsertChange * call InsertStatuslineColor(v:insertmode)
"[master]au InsertLeave * hi statusline guibg=white term=reverse ctermfg=0 ctermbg=white gui=bold,reverse"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"折叠
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"手动Fold,选中你要折的行,在Normal模式下 输入命令 zf% 折叠匹配的符号：(){}等
"当Fold创建后,移动光标到Fold所在行
"输入 zo, 打开相应的Fold
"zc, 关闭相应的Fold
"zM, 关闭文件中所有的Fold
"zR, 打开文件中所有的Fold
"za, 自动打开或关闭相应的Fold，只打开一个
"zd  删除 (delete) 在光标下的折叠。仅当 'foldmethod' 设为 "manual" 或 "marker" 时有效。
"zD  循环删除 (Delete) 光标下的折叠，即嵌套删除折叠。仅当 'foldmethod' 设为 "manual" 或 "marker" 时有效。
"zE  除去 (Eliminate) 窗口里“所有”的折叠.仅当 'foldmethod' 设为 "manual" 或 "marker" 时有效
"zf,创建折叠，输入移动命令，比如5j,于是折叠6行
set foldenable " 允许折叠"{{{
set foldmethod=manual " 手动折叠
set foldmethod=marker " 标志折叠
hi Folded term=standout ctermfg=4 ctermbg=red guifg=Black guibg=#e3c1a5"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function InsertHeadDef(firstLine, lastLine)"{{{
    "校验范围是否在当前Buffer的总行数之内
    if a:firstLine <1 || a:lastLine> line('$')
        echoerr 'InsertHeadDef : Range overflow !(FirstLine:'.a:firstLine.';LastLine:'.a:lastLine.';ValidRange:1~'.line('$').')'
        return "
    endif
    let sourcefilename=expand("%:t")
    let definename=substitute(sourcefilename,' ','','g')
    let definename=substitute(definename,'\.','_','g')
    let definename = toupper(definename)
    " 跳转到指定区域的第一行，开始操作
    exe 'normal '.a:firstLine.'GO'
    call setline('.', '#ifndef _'.definename."_")
    normal ==o
    call setline('.', '#define _'.definename."_")
    exe 'normal =='.(a:lastLine-a:firstLine+1).'jo'
    call setline('.', '#endif')
    " 跳转光标
    let goLn = a:firstLine+2
    exe 'normal =='.goLn.'G'
endfunction

function InsertHeadDefN()
    let firstLine = 30
    let lastLine = line('$')
    let n=1
    while n < 40
        let line = getline(n)
        if n==1
            if line =~ '^\/\*.*$'
                let n = n + 1
                continue
            else
                break
            endif
        endif
        if line =~ '^.*\*\/$'
            let firstLine = n+1
            break
        endif
        let n = n + 1
    endwhile
    call InsertHeadDef(firstLine, lastLine)
endfunction"}}}
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""新文件标题"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"因为filetype无法等于h，需要手动设置ft=h
autocmd BufNewFile *.h exec "set filetype=h"
"新建.c,.h,.sh,.java文件，自动插入文件头
autocmd BufNewFile *.cpp,*.[ch],*.sh,*.java,*.py exec ":call SetTitle()"
""定义函数SetTitle，自动插入文件头
func SetTitle()
   "如果文件类型为.sh文件
    if &filetype == 'sh'
        call setline(1,"\#!/bin/bash")
        call append(line("."), "")
    elseif &filetype == 'python'
        call setline(1,"#!/usr/bin/env python")
        call append(line("."),"# coding=utf-8")
        call append(line(".")+1, "")
        " elseif &filetype == 'mkd'
        " call setline(1,"<head><meta charset=\"UTF-8\"></head>")
    else
       call setline(1, "/*")
       call append(line("."), "Copyright (c) 2015, Intel Corporation. All rights reserved.")
       call append(line(".")+1, "*Redistribution and use in source and binary forms, with or without")
       call append(line(".")+2, "*modification, are permitted provided that the following conditions are met:")
       call append(line(".")+3, "*")
       call append(line(".")+4, "*1. Redistributions of source code must retain the above copyright notice,")
       call append(line(".")+5, "*this list of conditions and the following disclaimer.")
       call append(line(".")+6, "*")
       call append(line(".")+7, "*2. Redistributions in binary form must reproduce the above copyright notice,")
       call append(line(".")+8, "*this list of conditions and the following disclaimer in the documentation")
       call append(line(".")+9, "*and/or other materials provided with the distribution.")
       call append(line(".")+10, "*")
       call append(line(".")+11, "*3. Neither the name of the copyright holder nor the names of its contributors")
       call append(line(".")+12, "*may be used to endorse or promote products derived from this software without")
       call append(line(".")+13, "*specific prior written permission.")
       call append(line(".")+14, "*")
       call append(line(".")+15, "*THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 'AS IS'")
       call append(line(".")+16, "*AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE")
       call append(line(".")+17, "*IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE")
       call append(line(".")+18, "*ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE")
       call append(line(".")+19, "*LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR")
       call append(line(".")+20, "*CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF")
       call append(line(".")+21, "*SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS")
       call append(line(".")+22, "*INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN")
       call append(line(".")+23, "*CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)")
       call append(line(".")+24, "*ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE")
       call append(line(".")+25, "*POSSIBILITY OF SUCH DAMAGE.")
       call append(line(".")+26, "*/")
       call append(line(".")+27, "")
       ""call setline(1, "/*************************************************************************")
       ""call append(line("."), "    > File Name: ".expand("%"))
       ""call append(line(".")+1, "    > Author: sherlock.fang")
       ""call append(line(".")+2, "    > Mail: huix@fang.intel.com")
       ""call append(line(".")+3, "    > Created Time: ".strftime("%c"))
       ""call append(line(".")+4, " ************************************************************************/")
       ""call append(line(".")+5, "")
    endif
    if &filetype == 'cpp'
        " 跳转到指定区域的第一行，开始操作
        let fline = 30
        exe 'normal '.fline.'GO'
        call setline('.', "#include<stdio.h>")
        normal ==o
        call setline('.', "#include<stdlib.h>")
    endif
    if &filetype == 'c'
        " 跳转到指定区域的第一行，开始操作
        let fline = 30
        exe 'normal '.fline.'GO'
        call setline('.', "#include<stdio.h>")
        normal ==o
        call setline('.', "#include<stdlib.h>")
    elseif &filetype == 'h'
        call InsertHeadDefN()
        "再把filetype设置回来
        set filetype=c
    endif
    "    if &filetype == 'java'
    "     call append(line(".")+6,"public class ".strpart(expand("%d"),0,strlen(expand("%"))-5))
    "     call append(line(".")+7,"")
    "    endif
endfunc
"新建文件后，自动定位到文件末尾
autocmd BufNewFile * normal G"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"键盘命令"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map! <C-O> <C-Y>,
map <C-A> ggVG$"+y
"switch the c and h file
nnoremap <silent> <F12> :AV<CR>
"map <F12> gg=G
map <C-w> <C-w>w
" 选中状态下 Ctrl+c 复制
"map <C-v> "*pa
"imap <C-v> <Esc>"*pa
imap <C-v> <Esc>"+pa
imap <C-a> <Esc>^
vmap <C-c> "+y
"去空行
nnoremap <F2> :g/^\s*$/d<CR>"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"NERDTree Cooperate with Winmanager"{{{
"Winmanager:a window that can explore dir
"NERDTREE:a very simple tree to manage the dir
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F3> :NERDTreeToggle<CR>
imap <F3> <ESC> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeShowLineNumbers=1
let NERDChristmasTree=1
let NERDTreeHighlightCursorline=1
let NERDTreeChDirMode=2
let NERDTreeShowBookmarks=1
"let NERDTreeQuitOnOpen=1
:autocmd BufRead,BufNewFile *.dot map <F5> :w<CR>:!dot -Tjpg -o %<.jpg % && eog %<.jpg <CR><CR> && exec "redr!"
"当打开vim且没有文件时自动打开NERDTree
autocmd vimenter * if !argc() | NERDTree | endif
" 只剩 NERDTree时自动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
let g:winManagerWindowLayout='FileExplorer'
nmap wm :WMToggle<cr>"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"代码格式优化化"{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <F6> :call FormartSrc()<CR><CR>
"定义FormartSrc()
func FormartSrc()
    exec "w"
    if &filetype == 'c'
        exec "!astyle --style=ansi -a --suffix=none %"
    elseif &filetype == 'cpp' || &filetype == 'hpp'
        exec "r !astyle --style=ansi --one-line=keep-statements -a --suffix=none %> /dev/null 2>&1"
    elseif &filetype == 'perl'
        exec "!astyle --style=gnu --suffix=none %"
    elseif &filetype == 'py'||&filetype == 'python'
        exec "r !autopep8 -i --aggressive %"
    elseif &filetype == 'java'
        exec "!astyle --style=java --suffix=none %"
    elseif &filetype == 'jsp'
        exec "!astyle --style=gnu --suffix=none %"
    elseif &filetype == 'xml'
        exec "!astyle --style=gnu --suffix=none %"
    else
        exec "normal gg=G"
        return
    endif
    exec "e! %"
endfunc
"结束定义FormartSrc"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""实用设置
"some plguin:
""quickfix:just look up the compile err and warning
""buff explore:open history buff
"\be:norma open
"\bs:open buff horizal
"\bv:open buff vertical
"\b
""minibufexpl:mini window can exploer the buff that opened
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd FileType c,cpp map <buffer> <leader><space> :w<cr>:make<cr>"{{{
if has("autocmd")
    autocmd BufReadPost *
                \ if line("'\"") > 0 && line("'\"") <= line("$") |
                \ exe "normal g`\"" |
                \ endif
endif
" 设置当文件被改动时自动载入
set autoread
"quit the win:ALT+F11
nmap<M-F11> :q!<CR>"}}}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"cscope config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function Config_as_cscope(dir)"{{{
"if has('cscope')
    set csprg=/usr/bin/cscope

    if filereadable(a:dir . 'cscope.out')
        let cscope_file=findfile('cscope.out', '.;')
        let cscope_path=matchstr('cscope.out', a:dir)
        if  !filereadable(cscope_file)
            echo "[-vim-] NO cscope to be found"
            return 0
        endif

        if executable('cscope')
            echo "[-vim-] cscope is available"
            echo "[-vim-] Add cscope:". cscope_path . cscope_file
            exe "cs add" cscope_file cscope_path
        elseif
            echo "[-vim-] cscope is disable"
            return 0
        endif

    endif
    if filereadable(a:dir . 'tags')
        if executable('ctags')
            echo "[-vim-] ctags is available"
            execute 'set tags =' . a:dir . 'tags'
            echo "[-vim-] Add ctags:". a:dir . 'tags'
        elseif
            echo "[-vim-] ctags is disable"
            return 0
        endif
    endif
    return 1
endfunction"}}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"gtags-cscope config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! FindFiles(pat, ...)"{{{
     let path = ''
     for str in a:000
         let path .= str . ','
     endfor

     if path == ''
         let path = &path
     endif

     echo 'finding...'
     redraw
     call append(line('$'), split(globpath(path, a:pat), '\n'))
     echo 'finding...done!'
     redraw
endfunc

function! VimEnterCallback()
     for f in argv()
         if fnamemodify(f, ':e') != 'c' && fnamemodify(f, ':e') != 'h'
             continue
         endif

         call FindGtags(f)
     endfor
endfunc

function! FindGtags(f)
     let dir = fnamemodify(a:f, ':p:h')
     while 1
         let tmp = dir . '/GTAGS'
         if filereadable(tmp)
             exe 'cs add ' . tmp . ' ' . dir
             break
         elseif dir == '/'
             break
         endif

         let dir = fnamemodify(dir, ":h")
     endwhile
endfunc


function! UpdateGtags(f)
     let dir = fnamemodify(a:f, ':p:h')
     exe 'silent !cd ' . dir . ' && global -u &> /dev/null &'
     echo "[-vim-] update gtags of "a:f
 endfunction

function Enable_update_gtags()
    set cscopetag
    set cscopeprg=gtags-cscope
    set cscopequickfix=c-,d-,e-,f-,g0,i-,s-,t-
    nmap <silent> <leader>j <ESC>:cstag <c-r><c-w><CR>
    nmap <silent> <leader>g <ESC>:lcs f c <c-r><c-w><cr>:lw<cr>
    nmap <silent> <leader>s <ESC>:lcs f s <c-r><c-w><cr>:lw<cr>
    "command! -nargs=+ -complete=dir FindFiles :call FindFiles(<f-args>)
    "au VimEnter * call VimEnterCallback()
    "au BufAdd *.[ch] call FindGtags(expand('<afile>'))
    au BufWritePost *.[ch] call UpdateGtags(expand('<afile>'))
endfunc

function Config_as_gtags(dir)
    if filereadable(a:dir . 'GTAGS')
        let cscope_file=findfile('GTAGS', '.;')
        let cscope_path=matchstr('GTAGS', a:dir)
        if  !filereadable(cscope_file)
            echo "[-vim-] NO gtags to be found"
            return 0
        endif
        if executable('gtags-cscope')
            let g:GtagsCscope_Auto_Load = 1
            let g:GtagsCscope_Auto_Map = 1
            let g:GtagsCscope_Absolute_Path = 1
            set cscopetag
            set csprg=gtags-cscope
            call Enable_update_gtags()

            echo "[-vim-] gtags and gtags-cscope is available"
            echo "[-vim-] Add gtags-cscope:". cscope_path . cscope_file
            exe "cs add" cscope_file cscope_path

        elseif
            echo "[-vim-] gtags and gtags-cscope is disable"
            return 0
        endif

    endif
    return 1
endfunction"}}}

function Tags_config()
    set csto=0
    set cst
    set nocsverb
    set cspc=3
    let max = 4
    let dir = './'
    let i = 0
    let break = 0
    while isdirectory(dir) && i < max
        "let break = Config_as_cscope(dir)
        let break = Config_as_gtags(dir)

        if break == 1
            echo "[-vim-] break"
            let i = 0
            break
        endif
        let dir = dir . '../'
        let i = i + 1
    endwhile
    set  csverb
endfunction

call Tags_config()

"--------------------------------------------------------------------------
"vim-airline,状态栏
"--------------------------------------------------------------------------"{{{
set t_Co=256
set laststatus=2
set lazyredraw
"let g:airline_theme="molokai"
let g:airline_theme='powerlineish'
"打开会乱码
"let g:airline_powerline_fonts=1

"
"
"打开tabline功能,方便查看Buffer和切换,省去了minibufexpl插件
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_nr_show = 4

"设置切换Buffer快捷键"
"nnoremap <C-tab> :bn<CR>
"nnoremap <C-s-tab> :bp<CR>
" 关闭状态显示空白符号计数
let g:airline#extensions#whitespace#enabled = 0
let g:airline#extensions#whitespace#symbol = '!'

"设置tab和tab分隔符
let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#left_sep = ' '
"let g:airline#extensions#tabline#left_alt_sep = '|'
"
"show the func name in airline
let g:airline#extensions#tagbar#enabled = 1

if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
"" old vim-powerline symbols
"let g:airline_left_sep = '⮀'
"let g:airline_left_alt_sep = '⮁'
"let g:airline_right_sep = '⮂'
"let g:airline_right_alt_sep = '⮃'
"let g:airline_symbols.branch = '⭠'
"let g:airline_symbols.readonly = '⭤'
"
"改变默认的一项显示模式
let g:airline_section_y='%1*[%2*%{&ff}:%{&fenc}][ASCII=%03.3b][HEX=0x%02.2B]'

let g:airline_left_sep = '▶'
let g:airline_left_alt_sep = '>>>'
let g:airline_right_sep = '◀'
let g:airline_right_alt_sep = '<<<'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.readonly = ''
let g:airline_detect_modified=1
let g:airline_detect_paste=1
"}}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"some delay script
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"inoremap <expr> <C-r>* repeat('*', strdisplaywidth(getline(line('.')-1))-strdisplaywidth(getline('.')))"{{{
"行尾空格高亮,it must be settle on the end of .vimrc
"highlight WhitespaceEOL ctermbg=red  guibg=red
"match WhitespaceEOL /\s\+$/"}}}

"""""""""""显示行尾的tab和多余空格"""""""""""""""""""""""""""""""""""""""""""""""
set list
"set listchars=tab:>-,trail:~
"set listchars=tab:\|\ ,trail:.,extends:>,precedes:<,eol:$
set listchars=tab:\|\ ,trail:~
""if we want to highlight the tab and trail , you must take a script under .vimr/syntax/XXX.vim
hi Trail ctermbg=red  guibg=red
match Trail /\s\+$/
"hi TAB ctermbg=red  guibg=red
"syn match Trail /\v\*\=/
"syn match TAB /\t/
"


