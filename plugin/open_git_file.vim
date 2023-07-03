function! s:OpenPkgFile()
    let l:file_path = expand('%:p')
    let l:prefix = $GOPATH . '/pkg/mod/'
    let l:at_index = stridx(l:file_path, '@')
    if l:at_index < 0
        return
    endif
    let l:slash_index = stridx(l:file_path, '/', l:at_index + 1)
    if l:slash_index < 0
        return
    endif
    let l:version = l:file_path[l:at_index + 1 : l:slash_index - 1]
    if l:version =~ '\vv[\.0-9]+\-[0-9]+\-\w+'
        let l:branch = '/blob/' . l:version[strridx(l:version, "-") + 1:]
    elseif l:version =~ '\vv[\.0-9]+'
        let l:branch = '/tree/' . l:version
    else
        let l:branch = '/blob/master'
    endif
    let l:remote_url = 'https://' . l:file_path[strlen(l:prefix) : l:at_index - 1]
    let l:remote_url = l:remote_url . l:branch . l:file_path[l:slash_index:]
    let l:command = printf('open "%s"', l:remote_url)
    call system(l:command)
endfunction

function! OpenGitFile()
    let l:file_path = expand('%:p')
    let l:prefix = $GOPATH . '/pkg/mod/'
    if l:file_path =~ '\v' . l:prefix . '.+\.go'
        return s:OpenPkgFile()
    endif

    let l:git_root = system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
    if strlen(l:git_root) > 0
        let l:relative_path = fnamemodify(l:file_path, ':~:.')
        let l:remote_url = system('git config --get remote.origin.url')[:-2]
        let l:branch = system('git rev-parse --abbrev-ref HEAD')[:-2]

        if strlen(l:remote_url) > 0 && strlen(l:branch) > 0
            if l:remote_url =~ '^git@'
                let l:remote_url = substitute(l:remote_url, ':', '/', '')
                let l:remote_url = substitute(l:remote_url, '^git@', 'https://', '')
            endif

            let l:remote_url = substitute(l:remote_url, '\.git$', '', '') . '/blob/' . l:branch . '/' . l:relative_path
            let l:command = printf('open "%s"', l:remote_url)
            call system(l:command)
            return
        endif
    endif

    let l:command = printf('open "%s"', l:file_path)
    call system(l:command)
endfunction

command! OpenGitFile :call OpenGitFile()
