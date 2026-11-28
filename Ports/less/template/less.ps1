# {{meta.name}} for less: {{variant.name}}.
# Dot-source this from your profile ($PROFILE), after anything that sets LESS.
# It adds the colors to the end of LESS and keeps the options already there.
# The letters are terminal colors: set your terminal to {{variant.name}} too.
# Palette {{meta.version}}, {{meta.repository}}
$inglenookLess = '--use-color -DP{{port.text}}{{port.raised}}$ -DS{{port.raised}}b$ -DEr$ -DN{{port.faint}}$ -DMc$ -DB{{port.faint}}$ -DC{{port.faint}}$ -DR{{port.faint}}$ -DW{{port.text}}{{port.raised}}$ -Dd+b$ -Du+c$'
if (" $env:LESS " -notlike "* $inglenookLess *") {
    $env:LESS = if ($env:LESS) { "$env:LESS $inglenookLess" } else { "-R $inglenookLess" }
}
Remove-Variable inglenookLess
