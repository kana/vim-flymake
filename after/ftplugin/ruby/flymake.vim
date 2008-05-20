syntax on
set number

autocmd BufWritePost * :call FlyMake("cd %s; ruby -c %s", '.*:\([0-9]*\): \(.*\)', '.*:\([0-9]*\): \(.*\)')
autocmd BufWinLeave  * :call FlyMakeCloseWindows()
