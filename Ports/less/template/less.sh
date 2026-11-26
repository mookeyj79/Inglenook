# {{variant.name}} for less, from {{meta.name}} {{meta.version}}.
# Source this from your profile (~/.zshrc or ~/.bashrc), after anything that sets LESS.
# It adds the colors to the end of LESS and keeps the options already there.
# The letters are terminal colors: set your terminal to {{variant.name}} too.
inglenook_less='--use-color -DP{{port.text}}{{port.raised}}$ -DS{{port.raised}}y$ -DEr$ -DN{{port.faint}}$ -DMc$ -DB{{port.faint}}$ -DC{{port.faint}}$ -DR{{port.faint}}$ -DW{{port.text}}{{port.raised}}$ -Dd+b$ -Du+c$'
case " ${LESS-} " in
  *" $inglenook_less "*) ;;
  *) export LESS="${LESS:--R} $inglenook_less" ;;
esac
unset inglenook_less
