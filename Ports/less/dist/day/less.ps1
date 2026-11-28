# Inglenook for less: Inglenook Day.
# Dot-source this from your profile ($PROFILE), after anything that sets LESS.
# It adds the colors to the end of LESS and keeps the options already there.
# The letters are terminal colors: set your terminal to Inglenook Day too.
# Palette 1.0.0, https://github.com/mookeyj79/Inglenook
$inglenookLess = '--use-color -DPkW$ -DSWb$ -DEr$ -DNK$ -DMc$ -DBK$ -DCK$ -DRK$ -DWkW$ -Dd+b$ -Du+c$'
if (" $env:LESS " -notlike "* $inglenookLess *") {
    $env:LESS = if ($env:LESS) { "$env:LESS $inglenookLess" } else { "-R $inglenookLess" }
}
Remove-Variable inglenookLess
