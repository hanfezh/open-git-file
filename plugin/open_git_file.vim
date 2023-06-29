function! OpenGitFile()
    let file_path = expand('%:p')
    let git_root = system('git rev-parse --show-toplevel 2> /dev/null')[:-2]

    if strlen(git_root) > 0
        let relative_path = fnamemodify(file_path, ':~:.')
        let remote_url = system('git config --get remote.origin.url')[:-2]
        let branch = system('git rev-parse --abbrev-ref HEAD')[:-2]

        if strlen(remote_url) > 0 && strlen(branch) > 0
            if remote_url =~ '^git@'
                let remote_url = substitute(remote_url, ':', '/', '')
                let remote_url = substitute(remote_url, '^git@', 'https://', '')
            endif

            let remote_url = substitute(remote_url, '\.git$', '', '') . '/blob/' . branch . '/' . relative_path
            let command = printf('open "%s"', remote_url)
            call system(command)
            return
        endif
    endif

    let command = printf('open "%s"', file_path)
    call system(command)
endfunction

command! OpenGitFile :call OpenGitFile()
