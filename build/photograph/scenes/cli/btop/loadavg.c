/* btop's load average in the CLI/TUI scene (see stage.sh). glibc reads it from the
 * kernel, not from /proc, so proot cannot lay the machine's over it: this does. */
int getloadavg(double *loadavg, int nelem) {
    static const double machine[3] = {1.18, 0.94, 0.71};
    int i;
    for (i = 0; i < nelem && i < 3; i++) loadavg[i] = machine[i];
    return i;
}
