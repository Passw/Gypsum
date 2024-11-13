#!/usr/bin/env sh

# Checks if the $GUILE_REPL_IN_GDB variable has been exported as
# 'true' or 1, if so runs the Guile interpreter in GDB. This is so
# that segfaults caused by imported library code or by FFI code, can
# be caught and inspected.

GUILE_CMD_ARGS='guile --r7rs';
GUILE_CMD_ARGS="${GUILE_CMD_ARGS} --fresh-auto-compile";
GUILE_CMD_ARGS="${GUILE_CMD_ARGS} -L ${PWD}";

GUILE_REPL_IN_GDB=false;
GUILE_IN_GUIX_SHELL=false;

#export GDK_BACKEND='x11,wayland'
#export GTK_DEBUG='all'

#---------------------------------------------------------------------

if ${GUILE_IN_GUIX_SHELL}; then
   GUIX_SHELL_CMD='guix shell --pure -p ./.guix-profile --';
   echo 'Using guix shell to run Guile';
   echo "GUIX_SHELL_CMD=\"${GUIX_SHELL_CMD}\"";
else
   GUIX_SHELL_CMD='';
fi;

type guile;
echo "Guile CLI arguments: ${GUILE_CMD_ARGS} ${@}";

if ${GUILE_REPL_IN_GDB}; then
  exec ${GUIX_SHELL_CMD} \
    gdb \
      -ex 'handle SIGXCPU nostop' \
      -ex 'handle SIGPWR nostop' \
      -ex 'run' \
      --args \
        ${GUILE_CMD_ARGS} "${@}";
else
  exec ${GUIX_SHELL_CMD} ${GUILE_CMD_ARGS} "${@}";
fi;
