"-----------------------------------------------------------------------------
"plugins install
set nocompatible              " be iMproved, required 关闭vi兼容
filetype off                  " required 关闭文件类型检测

" set the runtime path to include Vundle and initialize 加入vundle路径后，可以直接调用vundle的插件函数
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"-----golang-------
Plugin 'fatih/vim-go'
Plugin 'SirVer/ultisnips'
Plugin 'ervandew/supertab' "for UltiSnips and YouCompleteMe conflict on [tab] button
Plugin 'ctrlpvim/ctrlp.vim' "for GoDecls,GoDeclsDir

"-----common------
Plugin 'AndrewRadev/splitjoin.vim' "将结构体分为多行或合并为一样，支持多种语言 gS 拆分 gJ 合并
Plugin 'scrooloose/nerdtree'
Plugin 'easymotion/vim-easymotion'
Plugin 'jiangmiao/auto-pairs' "括号等自动补全
Plugin 'Valloric/YouCompleteMe'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required 打开文件类型检测及载入文件类型相关的插件、缩进
" Put your non-Plugin stuff after this line


"-----------------------------------------------------------------------------
"common config
"
set nu
"set nowrap "取消自动换行
let mapleader = ","
syntax on "语法高亮
set backspace=2 "backspace失效问题
set maxmempattern=2000 "maxmempattern规定了vim做字符串匹配时使用的最大内存,解决E363: uses more memory than 'maxmempattern'


map  <Leader>w :w<CR> "

"QuickFix list
map <C-j> :cnext<CR>
map <C-k> :cprevious<CR>
nnoremap <leader>a :cclose<CR>

"-----------------------------------------------------------------------------
" for UltiSnips and YouCompleteMe conflict on [tab] button
"(detail: https://stackoverflow.com/questions/14896327/ultisnips-and-youcompleteme)
"let g:ycm_key_list_select_completion = ['<C-j>']
"let g:ycm_key_list_previous_completion = ['<C-k>']
""let g:SuperTabDefaultCompletionType = '<C-j>' "不确定有什么作用
"
"let g:UltiSnipsExpandTrigger = "<C-l>" "补全
"let g:UltiSnipsJumpForwardTrigger = "<C-j>" "下移动
"let g:UltiSnipsJumpBackwardTrigger = "<C-k>" "上移动



"-----------------------------------------------------------------------------
" nerdtree
"
" open a NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" change default arrows
let g:NERDTreeDirArrowExpandable = '+'
let g:NERDTreeDirArrowCollapsible = '-'


" 开启/关闭
map <Leader>nt :NERDTreeToggle<CR>
" 定位当前文件
map <Leader>nf :NERDTreeFind<CR>  



"-----------------------------------------------------------------------------
" vim-go
"
" help go-settings 查看所有的vim-go设定
"
" GoBuild or GoTestCompile based on the go file.
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
      call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
      call go#cmd#Build(0)
  endif
endfunction

" 4 space for tab
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4

" location list变为quickfix list,这样就可以使用一样的快捷键
let g:go_list_type = "quickfix"

" GoBuild, 自动保存内容(writes the content of the file automatically if you call :make.)
set autowrite

" GoInfo 光标移动时，自动调用
"let g:go_auto_type_info = 1
"set updatetime=800 "设置光标移动后，延迟多久go_auto_type_info生效.默认800ms

" GoImports 保存时,自动调用 (项目很大时可能会慢,可以考虑手动)
let g:go_fmt_command = "goimports"

" GoMetaLinter 保存时,自动调用(目前有bug需要先手动调用一次GoMetaLinter才生效)
"let g:go_metalinter_autosave = 1 "自动时发现会影响自动GoFmt
"let g:go_metalinter_autosave_enabled = ['vet', 'errcheck'] "自动调用时检测项
"let g:go_metalinter_enabled = ['vet', 'golint', 'errcheck'] " 手动调用时检测项
"let g:go_metalinter_deadline = "5s"
"let g:go_echo_command_info= 0 "调试用

let g:go_def_mode = 'godef'

" GoDecls 设置包含项
let g:go_decls_includes = "func,type"
" GoSameIds or GoSameIdsClear 光标移动时，高亮相同的标识符
let g:go_auto_sameids = 1

"高亮go tmplate
au BufRead,BufNewFile *.gohtml set filetype=gohtmltmpl



" GoBuild or GoTestCompile
autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>
" GoRun
autocmd FileType go nmap <leader>r  <Plug>(go-run)
" GoTest (GoTestFunc)
autocmd FileType go nmap <leader>t  <Plug>(go-test)
" GoCoverageToggle (其他GoCoverage,GoCoverageClear,GoCoverageBrowser)
autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)

" 跳转
" GoAlternate 在test文件和源文件切换
autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')
" GoDef or ctrl-] or gd
" GoDefPop or ctrl-t 回跳GoDef (相比vim自带的返回调转ctrl-O,会忽略掉期间的非GoDef的调转)
" GoDefStack 回到GoDef的最初位置
" GoDefStackClear
" GoDecls shows all type and function declarations for you
" GoDeclsDir
" motion objects:
"   ]] -> jump to next function
"   [[ -> jump to previous function
" guru:
"   GoReferrers finds references to the selected identifier
"   GoDescribe 类似GoInfo但更强
"   GoImplements 查实现了什么接口;接口有哪些实现
"   GoWhicherrs 看err可能的值(not work)
"   GoChannelPeers(not work)
"   GoCallees
"   GoCallers
"   GoCallstack(not work)
"   GoGuruScope

" 编辑
" two text objects, normal mode:
"   if， means inner function
"   af， means a function 默认包含文档（关闭 let g:go_textobj_include_function_doc = 0）
"     dif/daf 删除
"     yif/yaf 复制
"     vif/vaf 选择
" snippets, insert mode(需要'SirVer/ultisnips'插件):
"   tag (let g:go_addtags_transform = "camelcase" or "snake_case")
"   errp
"   errl
"   fn -> fmt.Println()
"   ff -> fmt.Printf()
"   ln -> log.Println()
"   lf -> log.Printf()

" 依赖
" GoImport 包，tab补全
" GoImportAs str strings
" GoDrop 包
" GoFiles
" GoDeps

" 提示
" GoInfo
"autocmd FileType go nmap <Leader>i <Plug>(go-info)
" GoDoc or K

" 检测
" GoLint
" GoVet
" GoErrCheck

" 重构
" GoRename
" GoFreevars

" 代码生成
" GoImpl

" 分享代码
" GoPlay


"--------------------------------------------------------------
" ctrlpvim/ctrlp.vim
let g:ctrlp_map = '<c-p>'
