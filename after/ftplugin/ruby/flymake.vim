" ruby/flymake - on-the-fly syntax checking for Ruby
" Version: 0.0.1-0
" Author: Daisuke Ikegami <ikegami@madscientist.jp>
" Copyright (C) 2008 Daisuke IKEGAMI
" ModifiedBy: kana <http://whileimautomaton.net/>
" Copyright (C) 2008 kana <http://whileimautomaton.net/>
" License: Modified BSD License (same as the original one)

if !exists('b:did_flymake')
  let b:did_flymake = 1

  autocmd BufWritePost <buffer>
  \ call FlyMake('cd %s; ruby -c %s',
  \              '.*:\([0-9]*\): \(.*\)',
  \              '.*:\([0-9]*\): \(.*\)')
  autocmd BufWinLeave <buffer>  call FlyMakeCloseWindows()
endif

" __END__
