" flymake - on-the-fly syntax checking
" Version: 0.0.1-0
" Author: Daisuke Ikegami <ikegami@madscientist.jp>
" Copyright (C) 2008 Daisuke IKEGAMI
" ModifiedBy: kana <http://whileimautomaton.net/>
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: Modified BSD License (same as the original one)

function FlyMakeCloseWindows()
  let bufs = ["*FlyMakeError*", "*FlyMakeWarn*"]
  for buf in bufs
    if buflisted(buf)
      call FlyMakeSendCommand(buf, "quit!")
   elseif bufwinnr(buf) != -1
      call FlyMakeSendCommand(buf, "quit!")
    endif
  endfor
endfunction

function! FlyMakeMoveWindow(buf_name, split)
  let cur = winnr()
  if !buflisted(a:buf_name)
    return -1
  else
    let winnr = bufwinnr(a:buf_name)
    if winnr == -1
      if a:split
        execute "sp " . a:buf_name
      else
        execute "b " . a:buf_name
      end
    else
      execute winnr . "wincmd w"
    endif
  endif
  return cur
endfunction

function! FlyMakeSendCommand(buf_name, cmd)
  let cur = FlyMakeMoveWindow(a:buf_name, 1)
  if cur != -1
    execute a:cmd
    execute cur . "wincmd w"
  else
    echo "FlyMakeSendCommand : " a:buf_name . " not exists."
  endif
endfunction

function! FlyMakeParseDictionary(msg, regexp)
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

function! FlyMakeTemporaryDirectory(dir)
  let tmp_dir = substitute(system("mktemp -d"), '\r\|\n', '', "g")
  call system("cp -a " . a:dir . "/* " . tmp_dir)
  return tmp_dir
endfunction

function! FlyMakeNumberSort(i1, i2)
  let n1 = str2nr(a:i1)
  let n2 = str2nr(a:i2)
  return n1 == n2 ? 0 : n1 > n2 ? 1 : -1
endfunction

function! FlyMakeDisplay(buf, type, msg, regexp)
  let dic = FlyMakeParseDictionary(a:msg, a:regexp)
  if len(keys(dic)) == 0
    return 0
  endif
  let sorted_keys = sort(keys(dic), "FlyMakeNumberSort")

  execute "match " . a:type . " '\\%" . sorted_keys[0] . "l'"
  call cursor(sorted_keys[0], 1)
  execute "10new " . a:buf
  for n in reverse(sorted_keys)
    for mes in reverse(dic[n])
      call FlyMakeSendCommand(a:buf, "call append(line($), \"" . n . ": " . a:type . " " . escape(mes, '()') . "\")")
    endfor
  endfor
  call FlyMakeSendCommand(a:buf, "call cursor(1, 1)")
  return len(keys(dic))
endfunction

function FlyMake(checker, err_regexp, warn_regexp)
  " set local variable
  let source_file = "%"
  let build_dir   = expand("%:p:h")

  call FlyMakeCloseWindows()

  " copy source files in build_dir into temp_dir
  let tmp_dir = FlyMakeTemporaryDirectory(build_dir)

  " run the external syntax checker command
  let command  = printf(a:checker, tmp_dir, expand("%:p:t"))
  let messages = split(system(command), '\n')

  " find erroneous lines by parsing the result string (maybe multi lines)
  let num_errors = FlyMakeDisplay("*FlyMakeError*", "Error", messages, a:err_regexp)

  " for each warning message, display it and highlight erroneous line
  if num_errors == 0
    call FlyMakeDisplay("*FlyMakeWarn*", "Todo", messages, a:warn_regexp)
  endif

  " cleanup
  call system("rm -r " . tmp_dir)
endfunction

" __END__
