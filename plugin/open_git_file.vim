function! s:ExecuteOpen(file_path)
    if has('mac')
        let l:command = printf('open "%s"', a:file_path)
        call system(l:command)
    elseif has('linux')
        let l:command = printf('xdg-open "%s"', a:file_path)
        call system(l:command)
    elseif has('win32')
        let l:command = printf('explorer "%s"', a:file_path)
        call system(l:command)
    endif
endfunction

function! s:OpenPkgFile(file_path, prefix)
    let l:at_idx = stridx(a:file_path, '@')
    if l:at_idx < 0
        return
    endif
    let l:slash_idx = stridx(a:file_path, '/', l:at_idx + 1)
    if l:slash_idx < 0
        return
    endif
    let l:version = a:file_path[l:at_idx + 1 : l:slash_idx - 1]
    if l:version =~ '\v^v[\.0-9]+\-[^-]+\-\w+$'
        let l:branch = '/blob/' .. l:version[strridx(l:version, "-") + 1:]
    elseif l:version =~ '\v^v[\.0-9]+$'
        let l:branch = '/blob/' .. l:version
    else
        let l:branch = '/blob/master'
    endif
    let l:remote_url = 'https://' .. a:file_path[strlen(a:prefix) : l:at_idx - 1]
    let l:remote_url = l:remote_url .. l:branch .. a:file_path[l:slash_idx:]
    let l:remote_url = l:remote_url .. '#L' .. string(line('.'))
    call s:ExecuteOpen(l:remote_url)
endfunction

function! s:OpenGitFile()
    let l:file_path = expand('%:p')
    let l:prefix = $GOPATH .. '/pkg/mod/'
    if l:file_path =~ '\v^' .. l:prefix .. '.+$'
        return s:OpenPkgFile(l:file_path, l:prefix)
    endif

    let l:git_root = system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
    if strlen(l:git_root) > 0 && l:file_path =~ l:git_root
        let l:relative_path = l:file_path[strlen(l:git_root):]
        let l:remote_url = system('git config --get remote.origin.url')[:-2]
        let l:branch = system('git rev-parse --abbrev-ref HEAD')[:-2]

        if strlen(l:remote_url) > 0 && strlen(l:branch) > 0
            if l:remote_url =~ '^git@'
                let l:remote_url = substitute(l:remote_url, ':', '/', '')
                let l:remote_url = substitute(l:remote_url, '^git@', 'https://', '')
            endif

            let l:remote_url = substitute(l:remote_url, '\.git$', '', '') .. '/blob/' .. l:branch 
            let l:remote_url = l:remote_url .. l:relative_path .. '#L' .. string(line('.'))
            call s:ExecuteOpen(l:remote_url)
            return
        endif
    endif

    call s:ExecuteOpen(l:file_path)
endfunction

command! OpenGitFile :call s:OpenGitFile()
