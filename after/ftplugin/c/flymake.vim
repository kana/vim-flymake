if !exists('b:did_flymake')
  let b:did_flymake = 1

  autocmd BufWritePost <buffer>
  \ call FlyMake('make -s -C %s check-syntax %s',
  \              '.*:\([0-9]*\): error: \(.*\)',
  \              '.*:\([0-9]*\): warning: \(.*\)')
  autocmd BufWinLeave <buffer>  call FlyMakeCloseWindows()
endif
