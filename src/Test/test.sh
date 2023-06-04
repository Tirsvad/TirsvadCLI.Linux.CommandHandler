#!/bin/bash

## @file
## @author Jens Tirsvad Nielsen
## @brief Test CommandHandler
## @details
## **Test Command Handler**

declare -g TEST_PATH_SCRIPTDIR="$(dirname "$(realpath "${BASH_SOURCE}")")"
declare -g TEST_PATH_APP=$(realpath "${TEST_PATH_SCRIPTDIR}/../CommandHandler")
declare -i -g TEST_PASSED=0
declare -i -g TEST_FAILED=0

## @fn info()
## @details
## **Info to screen**
## @param test message
info() {
  printf "          Test $1\r"
}

## @fn info_passed()
## @details
## **Info to screen**
## send "passed" in front of info message
## counting for later repport
info_passed() {
  printf " PASSED\n"
  TEST_PASSED+=1
}

## @fn info_passed()
## @details
## **Info to screen**
## send "failed" in front of info message
## counting for later repport
info_failed() {
  printf " FAILED\n"
  TEST_FAILED+=1
}

## @fn info_report()
## @details
## **Generate test repport**
info_report() {
  printf "\n\nTest result\n\n"
  printf "Passed ${TEST_PASSED}\n"
  printf "Failed ${TEST_FAILED}\n"
}


## @fn test_create_log_file()
test_create_log_file() {
	tcli_commandhandler_init 0
  info "test_create_log_file create directory and file"
  if tcli_logger_init "${TEST_PATH_SCRIPTDIR}/log/mytest.log"; then
    info_passed
  else
    info_failed
  fi
}

test_tcli_commandhandler_serverrootCmd() {
	tcli_commandhandler_init 0
  info "test_tcli_commandhandler_serverrootCmd local machine"
	cmd=(ls -la)
	# tcli_commandhandler_serverrootCmd_noWarning ${cmd[@]}

	tcli_commandhandler_serverrootCmd ${cmd[@]}
	if [ ! $? -eq 0 ]; then
		info_failed
	else
		info_passed
	fi

	tcli_commandhandler_init 1
  info "test_tcli_commandhandler_serverrootCmd remote machine"
	TCLI_COMMANDHANDLER_IP="127.0.0.1"
	TCLI_COMMANDHANDLER_PORT=22

	tcli_commandhandler_serverrootCmd ${cmd[@]}
	if [ ! $? -eq 0 ]; then
		info_failed
	else
		info_passed
	fi
}

test_tcli_commandhandler_serverrootCmd_noWarning() {
	tcli_commandhandler_init 0

}

. ../Vendor/Linux.Logger/src/Logger/run.sh

# test
test_create_log_file
. ../CommandHandler/run.sh
test_tcli_commandhandler_serverrootCmd


info_report

# rm -rf ${TEST_PATH_SCRIPTDIR}/log
