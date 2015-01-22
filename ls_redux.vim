source buffer_commands.vim

let file = expand('<sfile>:p:h')
let s:INDEX = file . '/index'

function! EditIndex()
  sp
  wincmd p
  call WriteLsToFile(s:INDEX)
  let numLines = line('$')
  if numLines < 4
    resize 4
  elseif numLines < 10
    resize numLines
  else
    resize 10
  endif
endfunction

nnoremap <leader>l :call EditIndex()<CR>

function! UpdateIndex()
  call WriteLsToFile(s:INDEX)
endfunction

function! UpdateBuffers()
  call DeleteUnwantedBuffers(s:INDEX)
  call OpenWantedBuffers(s:INDEX)
  call GoToSecondaryBuffer(s:INDEX)
  call WriteLsToFile(s:INDEX)
endfunction

function! OpenFileInLine()
  let b = getline('.')
  let name = BufferName(b)
  wincmd p
  try
    execute 'edit ' . name
  catch
    sp
    execute 'edit ' . name
  endtry
endfunction

autocmd bufwritepost index call UpdateBuffers()
autocmd bufwritepost index nnoremap <buffer> <CR> :call OpenFileInLine()<CR>
autocmd BufWinEnter index nnoremap <buffer> <CR> :call OpenFileInLine()<CR>
autocmd BufWinEnter index call WriteLsToFile(s:INDEX)

function! DeleteUnwantedBuffers(filename)
  let wanted = BufferNames(a:filename)
  let current = Map(function('BufferName'), split(GetLs(), '\n'))
  for b in current
    if index(wanted, b) < 0
      execute 'bd ' . b
    endif
  endfor
endfunction

function! OpenWantedBuffers(filename)
  let wanted = BufferNames(a:filename)
  let current = Map(function('BufferName'), split(GetLs(), '\n'))
  for b in wanted
    if index(current, b) < 0
      execute 'badd ' . b
    endif
  endfor
endfunction

function! WriteLsToFile(filename)
  execute 'drop ' . a:filename
  set nobuflisted
  call Clear()
  silent put = GetLs()
  call RemoveFirstTwoColumnsAndRows()
  execute 'write ' . a:filename
endfunction

function! OpenAllFilesInFile(filename)
  call Map(function('OpenBuffer'), readfile(a:filename))
endfunction

function! GoToPrimaryBuffer(filename)
  call GoToBasedOn(function('IsPrimaryBuffer'), a:filename)
endfunction

function! GoToSecondaryBuffer(filename)
  call GoToBasedOn(function('IsSecondaryBuffer'), a:filename)
endfunction

" Will filter the buffers in the file based on the function and go to the
" first of them if at least one exists
function! GoToBasedOn(fn, filename)
  let buffers = readfile(a:filename)
  let list = Filter(a:fn, buffers)
  if !empty(list)
    execute 'edit ' . BufferName(list[0])
  endif
endfunction

function! BufferNames(filename)
  return Map(function('BufferName'), readfile(a:filename))
endfunction

function! GetLs()
  redir => res
  silent ls
  redir end
  return res
endfunction

function! RemoveFirstTwoColumnsAndRows()
  normal! gg
  1,2d
  silent %s/^..//
endfunction

function! Map(fn, l)
  let new_list = deepcopy(a:l)
  call map(new_list, string(a:fn) . '(v:val)')
  return new_list
endfunction

function! Filter(fn, l)
  let new_list = deepcopy(a:l)
  call filter(new_list, string(a:fn) . '(v:val)')
  return new_list
endfunction

function! Clear()
  %d
endfunction
