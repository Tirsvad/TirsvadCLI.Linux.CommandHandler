#!/bin/bash

## @file
## @author Jens Tirsvad Nielsen
## @brief Command with ssh
## @details
## **Execute commands over ssh or localy**

declare IFS=$'\n'

## @brief string basepath of this script
declare -g -r TCLI_COMMANDHANDLER_SCRIPTDIR="$(dirname "$(realpath "${BASH_SOURCE}")")"
## @brief string basepath of this script
declare -g -r TCLI_COMMANDHANDLER_PATH_VENDOR="$(realpath "${TCLI_COMMANDHANDLER_SCRIPTDIR}/../Vendor")"
## @brief string version
declare -g TCLI_COMMANDHANDLER_VERSION
## @brief bool is server access remoted (false means server is the local machine)
declare -g TCLI_COMMANDHANDLER_ROMETE_SERVER
## @brief string IP address to conect server over ssh
declare -g TCLI_COMMANDHANDLER_IP
## @brief interger IP port to conect server over ssh
declare -g -i TCLI_COMMANDHANDLER_PORT
## @brief string contains output from the command that has been runned
declare -g TCLI_COMMANDHANDLER_TERMINAL_OUTPUT

## @fn tcli_commandhandler_init()
## @brief initialize
## @param bool server access remoted
tcli_commandhandler_init() {
	# loading vendor script
	if ! type -t tcli_logger_init >/dev/null; then
		. ${TCLI_COMMANDHANDLER_PATH_VENDOR}/Linux.Logger/src/Logger/run.sh
		tcli_logger_init
	fi
	
	TCLI_COMMANDHANDLER_ROMETE_SERVER=${1:-}
	[ $(cd $TCLI_SSH_SCRIPTDIR; git describe --tags 2>/dev/null) ] && TCLI_SSH_VERSION=$(cd $TCLI_SSH_SCRIPTDIR; git describe --tags) || TCLI_SSH_VERSION="build $(git rev-parse --short HEAD)"
	tcli_logger_file_info "Loaded" "TCLI Ssh $TCLI_SSH_VERSION"
}

## @fn tcli_commandhandler_serverrootCmd()
## @brief Connect server and an execute command as root
## @params Shell command
## @return true or false of command success
## @details
tcli_commandhandler_serverrootCmd_noWarning() {
	local -a _cmd
	if [ ${TCLI_COMMANDHANDLER_ROMETE_SERVER} -eq 1 ]; then
		printf "external server"
		_cmd=(ssh -p $TCLI_COMMANDHANDLER_PORT root@$TCLI_COMMANDHANDLER_IP)
		_cmd+=($@)
		# TCLI_COMMANDHANDLER_TERMINAL_OUTPUT=$("ssh -p $TCLI_COMMANDHANDLER_PORT root@$TCLI_COMMANDHANDLER_IP" $@)
	else
		_cmd=($@)
	fi
	TCLI_COMMANDHANDLER_TERMINAL_OUTPUT=$(${_cmd[@]})
	if [ ! $? -eq 0 ]; then
		tcli_logger_file_warn "Command executed but failed: $(echo ${_cmd[@]})" >&3
		return 1
	fi
	printf $TCLI_COMMANDHANDLER_TERMINAL_OUTPUT
	printf "Command executed: $(echo ${_cmd[@]})" >&3
}

## @fn tcli_ssh_serverrootCmd()
## @brief Connect server and an execute command as root
## @param Shell command
## @return true or false of command success
## @details
## 
## It will make a warning if it return false
tcli_commandhandler_serverrootCmd() {
	tcli_commandhandler_serverrootCmd_noWarning $@
	if [ ! $? -eq 0 ]; then
		tcli_logger_infoscreenWarn
		return 1
	fi
}
