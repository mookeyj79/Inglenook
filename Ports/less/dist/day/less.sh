# Inglenook for less: Inglenook Day.
# Source this from your profile (~/.zshrc or ~/.bashrc), after anything that sets LESS.
# It adds the colors to the end of LESS and keeps the options already there.
# The letters are terminal colors: set your terminal to Inglenook Day too.
# Palette 1.0.0, https://github.com/mookeyj79/Inglenook
inglenook_less='--use-color -DPkW$ -DSWb$ -DEr$ -DNK$ -DMc$ -DBK$ -DCK$ -DRK$ -DWkW$ -Dd+b$ -Du+c$'
case " ${LESS-} " in
  *" $inglenook_less "*) ;;
  *) export LESS="${LESS:--R} $inglenook_less" ;;
esac
unset inglenook_less
