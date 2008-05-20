" flymake - on-the-fly syntax checking
" Version: 0.0.1-0
" Author: Daisuke Ikegami <ikegami@madscientist.jp>
" Copyright (C) 2008 Daisuke IKEGAMI
" ModifiedBy: kana <http://whileimautomaton.net/>
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: Modified BSD License (same as the original one)

if exists('g:loaded_flymake') && g:loaded_flymake
  finish
endif




" Public

function! FlyMake(checker, err_regexp, warn_regexp)
  " set local variable
  let source_file = '%'
  let build_dir   = expand('%:p:h')

  call FlyMakeCloseWindows()

  " copy source files in build_dir into temp_dir
  let tmp_dir = s:FlyMakeTemporaryDirectory(build_dir)

  " run the external syntax checker command
  let command  = printf(a:checker, tmp_dir, expand('%:p:t'))
  let messages = split(system(command), '\n')

  " find erroneous lines by parsing the result string (maybe multi lines)
  let num_errors = s:FlyMakeDisplay('*FlyMakeError*', 'Error', messages,
  \                                 a:err_regexp)

  " for each warning message, display it and highlight erroneous line
  if num_errors == 0
    call s:FlyMakeDisplay('*FlyMakeWarn*', 'Todo', messages, a:warn_regexp)
  endif

  " cleanup
  call system('rm -r ' . tmp_dir)
endfunction


function! FlyMakeCloseWindows()
  let bufs = ['*FlyMakeError*', '*FlyMakeWarn*']
  for buf in bufs
    if bufexists(buf)
      call s:FlyMakeSendCommand(buf, bufnr(buf) . 'bwipeout')
    endif
  endfor
endfunction




" Private

function! s:FlyMakeMoveWindow(buf_name, split)
  let cur = winnr()
  if !bufexists(a:buf_name)
    return -1
  else
    let winnr = bufwinnr(a:buf_name)
    if winnr == -1
      execute bufnr(a:buf_name) (a:split ? 'sbuffer' : 'buffer')
    else
      execute winnr 'wincmd w'
    endif
  endif
  return cur
endfunction


function! s:FlyMakeSendCommand(buf_name, cmd)
  let cur = s:FlyMakeMoveWindow(a:buf_name, 1)
  if cur != -1
    execute a:cmd
    execute cur 'wincmd w'
  else
    echo 's:FlyMakeSendCommand :' a:buf_name 'does not exist.'
  endif
endfunction


function! s:FlyMakeParseDictionary(msg, regexp)
  let dic = {}
  for m in a:msg
    if m =~ a:regexp
      let l = matchlist(m, a:regexp)
      let line_no = l[1]
      let message = l[2]
      if has_key(dic, line_no)
        let dic[line_no] = add(dic[line_no], message)
      else
        let dic[line_no] = [message]
      endif
    endif
  endfor
  return dic
endfunction


function! s:FlyMakeTemporaryDirectory(dir)
  let tmp_dir = substitute(system('mktemp -d'), '\r\|\n', '', 'g')
  call system('cp -a ' . a:dir . '/* ' . tmp_dir)
  return tmp_dir
endfunction


function! s:FlyMakeNumberSort(i1, i2)
  let n1 = str2nr(a:i1)
  let n2 = str2nr(a:i2)
  return n1 == n2 ? 0 : n1 > n2 ? 1 : -1
endfunction


function! s:FlyMakeDisplay(buf, type, msg, regexp)
  let dic = s:FlyMakeParseDictionary(a:msg, a:regexp)
  if len(keys(dic)) == 0
    return 0
  endif
  let sorted_keys = sort(keys(dic), function('s:FlyMakeNumberSort'))

  execute 'match' a:type "'\\%" . sorted_keys[0] . "l'"
  call cursor(sorted_keys[0], 1)
  10 new
  setlocal bufhidden=wipe buftype=nofile noswapfile
  file `=a:buf`
  for n in reverse(sorted_keys)
    for mes in reverse(dic[n])
      call s:FlyMakeSendCommand(a:buf,
      \                         ('call append(line($), "' . n . ': '
      \                          . a:type . ' ' . escape(mes, '()') . '")'))
    endfor
  endfor
  call s:FlyMakeSendCommand(a:buf, 'call cursor(1, 1)')
  return len(keys(dic))
endfunction




let g:loaded_flymake = 1

" __END__
