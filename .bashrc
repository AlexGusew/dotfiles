#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
exec fish $LOGIN_OPTION

