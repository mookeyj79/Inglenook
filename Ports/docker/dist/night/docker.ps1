# Inglenook for Docker build output: Inglenook Night.
# Source this from your profile. Needs Docker with BuildKit (Docker 23 or newer).
# The names are terminal colors: set your terminal to Inglenook Night too.

# run: finished steps. cancel: canceled steps. warning: steps with a warning.
# error: the step that failed.
$env:BUILDKIT_COLORS = 'run=green:cancel=yellow:warning=yellow:error=red'
