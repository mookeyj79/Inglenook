# Inglenook Night for less, from Inglenook 0.1.0.
# Dot-source this from your profile ($PROFILE), after anything that sets LESS.
# It adds the colors to the end of LESS and keeps the options already there.
# The letters are terminal colors: set your terminal to Inglenook Night too.
$inglenookLess = '--use-color -DPWk$ -DSky$ -DEr$ -DNK$ -DMc$ -DBK$ -DCK$ -DRK$ -DWWk$ -Dd+b$ -Du+c$'
if (" $env:LESS " -notlike "* $inglenookLess *") {
    $env:LESS = if ($env:LESS) { "$env:LESS $inglenookLess" } else { "-R $inglenookLess" }
}
Remove-Variable inglenookLess
