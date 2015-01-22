" In a call to 'ls', the primary buffer is marked by a %
function! IsPrimaryBuffer(b)
  return BufferHeader(a:b) =~ "%"
endfunction

" In a call to 'ls', the primary buffer is marked by a #
function! IsSecondaryBuffer(b)
  return BufferHeader(a:b) =~ "#"
endfunction

" Given some string, the header is the section before the first quotation mark
function! BufferHeader(b)
  return split(' ' . a:b . ' ', '"')[0]
endfunction

" The name of the buffer is between the first and last quotation marks
function! BufferName(b)
  let ss = split(' ' . a:b . ' ', '"')
  let inOuterMostQuotes = ss[1:len(ss)-2]
  return join(inOuterMostQuotes, '\"')
endfunction

function! BufferLineNumber(b)
  let ss = split(' ' . a:b . ' ' , '"')
  let last = ss[len(ss)-1]
  let splitOnLine = split(last, 'line ')
  if len(splitOnLine) > 1
    return 0 + splitOnLine[1]
  else
    return 1
  endif
endfunction

" Add the given file to the buffer list
function! OpenBuffer(b)
  let name = BufferName(a:b)
  execute 'badd ' . name
endfunction

