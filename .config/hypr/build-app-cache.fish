#!/usr/bin/env fish

function icon_for --argument-names text
    set --local t (string lower -- $text)
    switch $t
        case '*terminal*' '*kitty*' '*alacritt*' '*foot*' '*konsole*' '*xterm*' '*wezterm*'
            echo ""
        case '*code*' '*codium*' '*vim*' '*emacs*' '*sublime*' '*jetbrains*' '*idea*' '*pycharm*' '*webstorm*' '*studio*'
            echo ""
        case '*firefox*' '*chrom*' '*brave*' '*opera*' '*vivaldi*' '*edge*' '*librewolf*' '*qutebrowser*' '*browser*'
            echo ""
        case '*files*' '*nautilus*' '*thunar*' '*dolphin*' '*nemo*' '*pcmanfm*' '*ranger*' '*filemanager*'
            echo ""
        case '*vlc*' '*mpv*' '*totem*' '*video*' '*obs*'
            echo ""
        case '*gimp*' '*inkscape*' '*viewer*' '*feh*' '*nomacs*' '*photo*' '*image*'
            echo ""
        case '*spotify*' '*audio*' '*music*' '*rhythmbox*' '*clementine*'
            echo ""
        case '*office*' '*libre*' '*writer*' '*calc*' '*impress*' '*word*' '*excel*' '*pdf*' '*document*'
            echo ""
        case '*discord*' '*telegram*' '*slack*' '*signal*' '*mail*' '*thunderbird*'
            echo ""
        case '*setting*' '*config*' '*preferences*' '*control*'
            echo ""
        case '*'
            echo ""
    end
end

set cache_file ~/.cache/app-index.tsv
rm -f $cache_file

for f in /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop
    test -f "$f"; or continue
    set --local name_line (grep -m1 '^Name=' "$f")
    test -n "$name_line"; or continue
    set --local name (string replace -r '^Name=' '' -- $name_line)
    set --local icon_line (grep -m1 '^Icon=' "$f")
    set --local icon_key (string replace -r '^Icon=' '' -- $icon_line)
    set --local glyph (icon_for "$icon_key $name")
    printf '%s  %s\t%s\n' "$glyph" "$name" "$f" >> $cache_file
end
