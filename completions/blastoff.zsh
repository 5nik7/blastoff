#compdef blastoff
# Offline filenames only; no application execution or TOML parsing.
_blastoff() {
    emulate -L zsh
    setopt extendedglob
    local LC_ALL=C root=${BLASTOFF_HOME:-$HOME/.config/blastoff}
    [[ $root == '~/'* ]] && root=$HOME/${root[3,-1]}
    local cur=$words[CURRENT] word pending=0 literal=0 i
    local -a positional candidates files
    for ((i=2; i<CURRENT; i++)); do
        word=$words[i]
        if ((pending)); then pending=0; continue; fi
        if ((!literal)); then
            case $word in
                --) literal=1; continue ;;
                --json|--force|--replace-link) continue ;;
                --color) pending=1; continue ;;
                --color=*) continue ;;
            esac
        fi
        if ((${#positional} == 0)); then
            case $word in
                -l|--list) positional+=(list); continue ;;
                -t|--theme) positional+=(theme apply); continue ;;
            esac
        fi
        positional+=("$word")
    done
    local command=$positional[1] action=$positional[2] count=${#positional}
    local kind='' prefix='' file base upper value
    if ((pending)); then candidates=(auto always never)
    elif ((!literal)) && [[ $cur == --color=* ]]; then candidates=(--color=auto --color=always --color=never)
    elif ((!literal)) && [[ $cur == -* ]]; then
        candidates=(-h --help --json --color --force --replace-link)
        ((count)) || candidates+=(--version -l --list -t --theme)
    elif ((count == 0)); then
        candidates=(list current pick doctor theme preset module backup migrate completion)
    elif ((count == 1)); then
        case $command in
            theme) candidates=(list apply save copy import delete) ;;
            preset) candidates=(list apply save) ;;
            module) candidates=(list save load delete) ;;
            backup) candidates=(create list restore) ;;
            completion) candidates=(bash zsh fish) ;;
            migrate) _files -/; return ;;
        esac
    elif ((count == 2)); then
        case $command:$action in
            theme:apply|theme:copy)
                kind=themes
                case $cur in
                    local:*) prefix=local: ;;
                    preset:*) kind='' ;;
                    *) candidates=(local: preset:) ;;
                esac ;;
            theme:delete) kind=themes ;;
            module:load|module:delete) kind=modules ;;
            backup:restore) kind=backups ;;
            theme:import) _files; return ;;
        esac
    fi
    if [[ -n $kind && -d $root && ! -L $root/$kind ]]; then
        files=("$root/$kind/"*.toml(N))
        for file in "${files[@]}"; do
            [[ -f $file && ! -L $file ]] || continue
            base=${file:t:r}; upper=${(U)base}
            [[ ${#base} -le 96 && $base == [A-Za-z0-9][A-Za-z0-9_-]# ]] || continue
            case $upper in CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9]) continue ;; esac
            # Metadata is not read: candidates have unverified backup kinds.
            if [[ $kind == backups ]]; then
                [[ -f $root/$kind/$base.json && ! -L $root/$kind/$base.json ]] || continue
            fi
            candidates+=("$prefix$base")
        done
    fi
    # Filter explicitly too, so dispatch remains testable outside ZLE.
    local -a names prefixes
    for value in "${candidates[@]}"; do
        [[ $value == "$cur"* ]] || continue
        if [[ $value == *: ]]; then prefixes+=("$value")
        else names+=("$value"); fi
    done
    ((${#names})) && compadd -a names
    ((${#prefixes})) && compadd -S '' -a prefixes
    return 0
}
# Works both as a sourced script (after compinit) and as an autoloaded _blastoff.
if [[ $funcstack[1] == _blastoff ]]; then
    _blastoff "$@"
elif (( $+functions[compdef] )); then
    compdef _blastoff blastoff
fi
