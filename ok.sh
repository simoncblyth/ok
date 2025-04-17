#!/bin/bash
usage(){ cat << EOU
ok.sh : testing Opticks binary release environment
====================================================

Usage:

0. clone OK repo::

   git clone https://github.com/simoncblyth/ok.git
   git clone git@github.com:simoncblyth/ok.git

1. use "env" to check if some of the Opticks runtime envvars
   are already present. If so then change .bash_profile .bashrc etc..
   to remove that setup then exit your session and start new one.

2. repeat 1. until you get a clean env

3. add some bash functions to work with this script::

    ok(){ source ~/ok/ok.sh $* ; }
    okv(){ vi ~/ok/ok.sh ; }
    t(){ typeset -f $* ; }

4. check some commands::

    ok env_test0


NB : YOU DO NOT NEED TO USE THIS SCRIPT : INSTEAD MAKE YOUR OWN
------------------------------------------------------------------

eg::

    #!/bin/bash
    source /cvmfs/opticks.ihep.ac.cn/ok/releases/el9_amd64_gcc11/Opticks-vLatest/bashrc
    cxr_min.sh
    #G4CXTest_raindrop.sh


EOU
}

defarg="info_env_evt_test0"
arg=${1:-$defarg}

vars="0 defarg arg"

if [ "${arg/info}" != "$arg" ] ; then
   for var in $vars ; do printf "%20s : %s\n" "$var" "${!var}" ; done
fi

if [ "${arg/env}" != "$arg" ] ; then

    envset=/cvmfs/opticks.ihep.ac.cn/ok/releases/el9_amd64_gcc11/Opticks-vLatest/bashrc
    _envset=$(realpath $envset)

    echo [ env - source ${_envset}
    source ${_envset}
    echo ] env - source ${_envset}

    export OPTICKS_SCRIPT=ok_sh
    export OK_LOGDIR=/tmp/$USER/opticks/GEOM/$GEOM/$OPTICKS_SCRIPT
    ok_find(){ find $OK_LOGDIR -name '*.npy' ; }

    env | grep OJ_
fi


logging(){
    type $FUNCNAME
    #export QEvent=INFO
    export QU=INFO
}
[ -n "$LOG" ] && logging


if [ "${arg/dbg}" != "$arg" ] ; then

    echo [ dbg
    ## optionally enable saving of Debug photon history arrays
    export OPTICKS_EVENT_MODE=DebugLite
    if [ "$OPTICKS_EVENT_MODE" == "DebugLite" ]; then
        export OPTICKS_MAX_SLOT=M1
        ## with debug arrays enabled must limit max slot to avoid VRAM OOM
    fi
    echo ] dbg

fi


regex="test([0-9])"
if [[ $arg =~ $regex ]]; then

   m0=${BASH_REMATCH[0]}
   m1=${BASH_REMATCH[1]}
   case $m1 in
     0) cmdline="cxr_min.sh" ;;
     1) cmdline="G4CXTest_raindrop.sh" ;;
     2) cmdline="gdb -ex r --args $(which CSGOptiXRenderInteractiveTest)" ;;
     3) cmdline="FULLSCREEN=1 EYE=1,0,0 LOOK=0,0,0 UP=0,0,1 ZOOM=1 ESCALE=extent WH=2560,1440 CSGOptiXRenderInteractiveTest" ;;
     *) cmdline="" ;;
   esac

   vv="arg regex m0 m1 cmdline"
   for v in $vv ; do printf "%20s : %s\n" "$v" "${!v}" ; done

fi


if [ -n "$cmdline" ]; then

    echo [ cmdline - $cmdline
    iwd=$PWD

    if [ -n "$OK_LOGDIR" ]; then
       echo $0 OK_LOGDIR $OK_LOGDIR
       mkdir -p $OK_LOGDIR && cd $OK_LOGDIR && pwd
    fi

    echo $cmdline
    eval $cmdline

    if [ -n "$OK_LOGDIR" ]; then
       pwd
       echo $0 OK_LOGDIR $OK_LOGDIR
       ls -alst $OK_LOGDIR
    fi

    cd $iwd && pwd
    echo ] cmdline - $cmdline
fi


