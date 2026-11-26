# Inglenook Night for less, from Inglenook 0.1.0.
# Source this from your profile (~/.zshrc or ~/.bashrc), after anything that sets LESS.
# It adds the colors to the end of LESS and keeps the options already there.
# The letters are terminal colors: set your terminal to Inglenook Night too.
inglenook_less='--use-color -DPWk$ -DSky$ -DEr$ -DNK$ -DMc$ -DBK$ -DCK$ -DRK$ -DWWk$ -Dd+b$ -Du+c$'
case " ${LESS-} " in
  *" $inglenook_less "*) ;;
  *) export LESS="${LESS:--R} $inglenook_less" ;;
esac
unset inglenook_less
