# Inglenook for less: Inglenook Night.
# Dot-source this from your profile ($PROFILE), after anything that sets LESS.
# It adds the colors to the end of LESS and keeps the options already there.
# The letters are terminal colors: set your terminal to Inglenook Night too.
# Palette 0.1.1, https://github.com/mookeyj79/Inglenook
$inglenookLess = '--use-color -DPWk$ -DSkb$ -DEr$ -DNK$ -DMc$ -DBK$ -DCK$ -DRK$ -DWWk$ -Dd+b$ -Du+c$'
if (" $env:LESS " -notlike "* $inglenookLess *") {
    $env:LESS = if ($env:LESS) { "$env:LESS $inglenookLess" } else { "-R $inglenookLess" }
}
Remove-Variable inglenookLess
