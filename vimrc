call plug#begin('~/.vim/plugged')
	Plug 'kaicataldo/material.vim'
	Plug 'itchyny/lightline.vim'
	Plug 'tpope/vim-fugitive'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'neoclide/coc-json', {'do': 'yarn install --frozen-lockfile'}
	Plug 'neoclide/coc-python', {'do': 'yarn install --frozen-lockfile'}
	Plug 'fannheyward/coc-texlab', {'do': 'yarn install --frozen-lockfile'}
call plug#end()

filetype plugin indent on
syntax on

set autochdir
set autowrite
set backspace=indent,eol,start
set belloff=all
set hidden
set hlsearch
set guioptions+=!
set guioptions+=d
set guioptions+=k
set guioptions-=t
set guioptions-=T
set laststatus=2
set nobackup
set nowritebackup
set shiftwidth=4
set shortmess+=c
set showcmd
set signcolumn=yes
set switchbuf=newtab,usetab
set tabstop=4
set updatetime=300
set whichwrap+=<,>,[,]

if has('termguicolors')
	set termguicolors
endif

let g:gtk_nocache = [0x00000000, 0xfc00ffff, 0xf8000001, 0x78000001]

let g:material_theme_style = 'darker'
colorscheme material

let s:ansi_colors = ['black', 'red', 'green', 'yellow', 'blue', 'purple', 'cyan', 'white']
let s:colors = g:material_colorscheme_map
let s:ansi_colors = map(s:ansi_colors, 's:colors[v:val]')
let g:terminal_ansi_colors = s:ansi_colors + s:ansi_colors

"function! s:hex2rgb(hex)
"	let l:nums = map([1, 3, 5], 'str2nr(a:hex[v:val:v:val + 1], 16)')
"	return 'rgb(' . join(l:nums, ',') . ')'
"endfunction
"let g:gnome_terminal_background = s:hex2rgb(s:colors['bg'])
"let g:gnome_terminal_foreground = s:hex2rgb(s:colors['fg'])
"let g:gnome_terminal_palette = map(g:terminal_ansi_colors, 's:hex2rgb(v:val)')

let g:lightline = {
\	'colorscheme': 'material_vim',
\	'active': {
\		'left': [
\			['mode', 'paste'],
\			['currentfunction', 'readonly', 'filename', 'modified']
\		],
\		'right': [
\			['lineinfo'],
\			['fileformat', 'fileencoding', 'filetype']
\		]
\	},
\	'inactive': {
\		'right': [
\			['lineinfo'],
\		]
\	},
\	'component': {
\		'currentfunction': '%{get(b:, "coc_current_function", "")}'
\	},
\	'component_visible_condition': {
\		'currentfunction': 'exists("b:coc_current_function")&&b:coc_current_function!=""'
\	}
\}


function! CloseTerminalOnSuccess(job, status)
	if a:status == 0
		let l:channel = job_getchannel(a:job)
		let l:buffer = ch_getbufnr(l:channel, 'out')
		if l:buffer >= 0
			execute 'bdelete' . l:buffer
		endif
	endif
endfunction

function! s:runcmd(...)
	if &modified
		write
	endif
	call term_start(a:000, {'exit_cb': 'CloseTerminalOnSuccess'})
endfunction


let g:tex_flavor = 'latex'

function! s:runlatex()
	call <SID>runcmd('lualatex', '--halt-on-error', @%)
endfunction

function! s:runbibtex()
	call <SID>runcmd('bibtex', expand('%:r'))
endfunction

augroup latex
	autocmd!
	autocmd FileType tex noremap <buffer> <F5> :call <SID>runlatex()<CR>
	autocmd FileType tex inoremap <buffer> <F5> <C-O>:call <SID>runlatex()<CR>
	autocmd FileType bib noremap <buffer> <F5> :call <SID>runbibtex()<CR>
	autocmd FileType bib inoremap <buffer> <F5> <C-O>:call <SID>runbibtex()<CR>
augroup end


function! s:checkbackspace() abort
	let col = col('.') - 1
	return !col || getline('.')[col - 1] =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
\	pumvisible()? "\<C-n>":
\	<SID>checkbackspace()? "\<Tab>":
\	coc#refresh()
inoremap <expr> <S-Tab> pumvisible()? "\<C-p>": "\<S-Tab>"
inoremap <silent><expr> <C-Space> coc#refresh()
inoremap <expr> <CR> pumvisible()? "\<C-y>": "\<C-g>u\<CR>"

function! s:showdocs()
	if index(['vim', 'help'], &filetype) >= 0
		execute 'help' expand('<cword>')
	else
		call CocAction('doHover')
	endif
endfunction

nnoremap <silent> K :call <SID>showdocs()<CR>

augroup coc
	autocmd!
	autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
	autocmd User CocStatusChange call lightline#update()
augroup end
