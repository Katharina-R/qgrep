function! qgrep#utils#syntax()
	return has('syntax') && exists('g:syntax_on')
endfunction

function! qgrep#utils#splitex(input)
    let pos = stridx(a:input, ':')
    let pos = pos < 0 ? len(a:input) : pos
    return [strpart(a:input, 0, pos), strpart(a:input, pos)]
endfunction

function! s:jumpCmd(cmd)
    if a:cmd != ''
        silent! execute a:cmd
        silent! normal! zvzz
    endif
endfunction

function! s:gotoFile(path, mode, cmd)
    let path = fnamemodify(a:path, ':p')
    let mode = split(a:mode, ',')

    let buf = bufnr('^'.path.'$')

    if (count(mode, 'useopen') || count(mode, 'usetab')) && buf >= 0
        let win = bufwinnr(buf)
        if win >= 0
            execute win . 'wincmd w'
            return s:jumpCmd(a:cmd)
        endif

        if count(mode, 'usetab')
            let [tab, win] = s:tabpagebufwinnr(buf)
            if tab >= 0 && win >= 0
                execute 'tabnext' (tab + 1)
                execute win . 'wincmd w'
                return s:jumpCmd(a:cmd)
            endif
        endif
    endif

    if count(mode, 'newtab')
        execute 'tabedit' path
    elseif count(mode, 'split')
        execute 'split' path
    elseif count(mode, 'vsplit')
        execute 'vsplit' path
    else
        execute 'edit' path
    endif

    return s:jumpCmd(a:cmd)
endfunction

function! qgrep#utils#gotoFile(path, mode, cmd)
    try
        call s:gotoFile(a:path, a:mode, a:cmd)
    catch
        echohl ErrorMsg
        echo v:exception
    endtry
endfunction
