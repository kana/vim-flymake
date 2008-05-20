if !exists('b:did_flymake')
  let b:did_flymake = 1

  autocmd BufWritePost <buffer>
  \ call FlyMake('cd %s; ruby -c %s',
  \              '.*:\([0-9]*\): \(.*\)',
  \              '.*:\([0-9]*\): \(.*\)')
  autocmd BufWinLeave <buffer>  call FlyMakeCloseWindows()
endif
