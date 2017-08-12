" Vim syntax file
" Language: Vue.js
" Maintainer: Eduardo San Martin Morote

if exists("b:current_syntax")
  finish
endif

runtime! syntax/html.vim
unlet! b:current_syntax

""
" Get the pattern for a HTML {name} attribute with {value}.
function! s:attr(name, value)
  return a:name . '=\("\|''\)[^\1]*' . a:value . '[^\1]*\1'
endfunction

""
" Check whether a syntax file for a given {language} exists.
function! s:syntax_available(language)
  return !empty(globpath(&runtimepath, 'syntax/' . a:language . '.vim'))
endfunction

""
" Set default value of global variable
function! s:set(var, default) abort
  if !exists(a:var)
    if type(a:default)
      execute 'let' a:var '=' string(a:default)
    else
      execute 'let' a:var '=' a:default
    endif
  endif
endfunction

""
" Register {language} for a given {tag}. If [attr_override] is given and not
" empty, it will be used for the attribute pattern.
function! s:register_language(language, tag, ...)
  let attr_override = a:0 ? a:1 : ''
  let attr = !empty(attr_override) ? attr_override : s:attr('lang', a:language)

  if s:syntax_available(a:language)
    execute 'syntax include @' . a:language . ' syntax/' . a:language . '.vim'
    unlet! b:current_syntax
    execute 'syntax region vue_' . a:language
          \ 'keepend'
          \ 'matchgroup=vueTag'
          \ 'start=/<' . a:tag . ' \_[^>]*' . attr . '\_[^>]*>/'
          \ 'end="</' . a:tag . '>"'
          \ 'contains=@' . a:language . ',vueSurroundingTag'
          \ 'fold'
  endif
endfunction

""
" Register for deafult languge if user doesn't give the specific language
" e.g. <script> ... </script>
function! s:register_defalut_language(language, tag)
  execute 'syntax region vue_defalut_'.a:tag
        \ 'keepend'
        \ 'matchgroup=vueTag'
        \ 'start="<'.a:tag.'>"'
        \ 'end="</'.a:tag.'>"'
        \ 'contains=@'.a:language.',vueSurroundingTag'
        \ 'fold'
endfunction

if !exists("g:vue_disable_pre_processors") || !g:vue_disable_pre_processors

  call s:register_language('html'      , 'template')
  call s:register_language('pug'       , 'template', s:attr('lang', '\%(pug\|jade\)'))
  call s:register_language('slm'       , 'template')
  call s:register_language('handlebars', 'template')
  call s:register_language('haml'      , 'template')

  call s:register_language('javascript', 'script', s:attr('lang', '\%(js\|javascript\)'))
  call s:register_language('ls'        , 'script', s:attr('lang', '\%(ls\|livescript\)'))
  call s:register_language('typescript', 'script', '\%(lang=\("\|''\)[^\1]*\(ts\|typescript\)[^\1]*\1\|ts\)')
  call s:register_language('coffee'    , 'script')

  call s:register_language('css'       , 'style')
  call s:register_language('stylus'    , 'style')
  call s:register_language('sass'      , 'style')
  call s:register_language('scss'      , 'style')
  call s:register_language('less'      , 'style')

endif

call s:set("g:vue_default_template_lang", "html")
call s:set("g:vue_default_script_lang"  , "javascript")
call s:set("g:vue_default_style_lang"   , "css")
call s:set("g:vue_tag_color"            , "Blue")

call s:register_defalut_language(g:vue_default_template_lang, 'template')
call s:register_defalut_language(g:vue_default_script_lang  , 'script')
call s:register_defalut_language(g:vue_default_style_lang   , 'style')

syn region  vueSurroundingTag   contained start=+<\(script\|style\|template\)+ end=+>+ fold contains=htmlTagN,htmlString,htmlArg,htmlValue,htmlTagError,htmlEvent
syn keyword htmlSpecialTagName  contained template
syn keyword htmlArg             contained scoped ts
syn match   htmlArg "[@v:][-:.0-9_a-z]*\>" contained

exec 'highlight vueTag ctermfg='.g:vue_tag_color

let b:current_syntax = "vue"
