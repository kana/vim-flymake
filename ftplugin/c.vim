syntax on
set number

autocmd BufWritePost * :call FlyMake("make -s -C %s check-syntax %s", '.*:\([0-9]*\): error: \(.*\)', '.*:\([0-9]*\): warning: \(.*\)')
autocmd BufWinLeave  * :call FlyMakeCloseWindows()
