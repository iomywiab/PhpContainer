#!/bin/bash

DIR=$(cd "$(dirname "${0}")"; pwd) || exit
cd "${DIR}" || exit

BUILD="${DIR}/build-one.sh"
LOGFILE="${DIR}/temp/build.log"
date > "${LOGFILE}"

# check parameters
PARAM_PHP_VERSION=${1}
PARAM_BINARY_TYPE=${2}
PARAM_DEBUG_TYPE=${3}
PARAM_DOCKER_TAG=${4}
ERROR_PREFIX="ERROR......:"
SUPPORTED_PHP_VERSIONS=("5.6" "7.1" "7.2" "7.3" "7.4" "8.0" "8.1" "8.2" "8.3" "8.4")
SUPPORTED_BINARY_TYPES=("cli" "apache")
SUPPORTED_DEBUG_TYPES=("nodebug" "debug")
DEFAULT_PHP_VERSION="8.4"
DEFAULT_BINARY_TYPE="cli"
DEFAULT_DEBUG_TYPE="debug"
DEFAULT_DOCKER_TAG="latest"

function echoSyntax () {
   echo "Syntax.....: ${0} [version] [binary-type] [debug-type] [docker-tag]"
   echo "version....: all | "$(printf '%s | ' "${SUPPORTED_PHP_VERSIONS[@]}")" (default: ${DEFAULT_PHP_VERSION})"
   echo "binary-type: all | "$(printf '%s | ' "${SUPPORTED_BINARY_TYPES[@]}")" (default: ${DEFAULT_BINARY_TYPE})"
   echo "debug-type.: all | "$(printf '%s | ' "${SUPPORTED_DEBUG_TYPES[@]}")" (default: ${DEFAULT_DEBUG_TYPE})"
   echo "docker-tag.: a tag as used in Docker registry (default: latest)"
}


if [ -z "${PARAM_PHP_VERSION}" ]; then
  PHP_VERSION=("${DEFAULT_PHP_VERSION}")
elif [ "all" == "${PARAM_PHP_VERSION}" ]; then
  PHP_VERSION=( "${SUPPORTED_PHP_VERSIONS[@]}" )
elif [[ " ${SUPPORTED_PHP_VERSIONS[*]} " = *"${PARAM_PHP_VERSION}"* ]]; then
  PHP_VERSION=("${PARAM_PHP_VERSION}")
else
   echo "${ERROR_PREFIX} Unknown parameter #1 [version]: ${PARAM_PHP_VERSION}"
   echoSyntax
   exit
fi
echo "PHP version(s) to be built: ${PHP_VERSION[*]}"

# reverse version order (newer version are of more interest and should be provided faster)
reversed_array=()
for ((i=${#PHP_VERSION[@]}-1; i>=0; i--)); do
    reversed_array+=("${PHP_VERSION[i]}")
done
PHP_VERSION=( "${reversed_array[@]}" )

if [ -z "${PARAM_BINARY_TYPE}" ]; then
  BINARY_TYPE=("${DEFAULT_BINARY_TYPE}")
elif [ "all" == "${PARAM_BINARY_TYPE}" ]; then
  BINARY_TYPE=( "${SUPPORTED_BINARY_TYPES[@]}" )
elif [[ " ${SUPPORTED_BINARY_TYPES[*]} " = *"${PARAM_BINARY_TYPE}"* ]]; then
  BINARY_TYPE=("${PARAM_BINARY_TYPE}")
else
   echo "${ERROR_PREFIX} Unknown parameter #2 [binary-type]: ${PARAM_BINARY_TYPE}"
   echoSyntax
   exit
fi
echo "Binary type(s) to be built: ${BINARY_TYPE[*]}"


if [ -z "${PARAM_DEBUG_TYPE}" ]; then
  DEBUG_TYPE=("${DEFAULT_DEBUG_TYPE}")
elif [ "all" == "${PARAM_DEBUG_TYPE}" ]; then
  DEBUG_TYPE=( "${SUPPORTED_DEBUG_TYPES[@]}" )
elif [[ " ${SUPPORTED_DEBUG_TYPES[*]} " = *"${PARAM_DEBUG_TYPE}"* ]]; then
  DEBUG_TYPE=("${PARAM_DEBUG_TYPE}")
else
   echo "${ERROR_PREFIX} Unknown parameter #3 [debug-type]: ${PARAM_DEBUG_TYPE}"
   echoSyntax
   exit
fi
echo "Debug type(s) to be built: ${DEBUG_TYPE[*]}"


if [ -z "${PARAM_DOCKER_TAG}" ]; then
  DOCKER_TAG="${DEFAULT_DOCKER_TAG}"
else
  DOCKER_TAG="${PARAM_DOCKER_TAG}"
fi
echo "Building with docker tag '${DOCKER_TAG}'..."


#Syntax.....: ${0} [version] [binary-type] [debug-type] [docker-tag]"

#Attention: debug is based on nodebug. run nodebug first, then debug!


for version in "${PHP_VERSION[@]}"
do
  for binary in "${BINARY_TYPE[@]}"
  do
    for debug in "${DEBUG_TYPE[@]}"
    do
       "${BUILD}" "${version}" "${binary}" "${debug}" "${DOCKER_TAG}" 2>&1 | tee -a "${LOGFILE}"
    done
  done
done
exit

#echo PHPStorm+PHPUnit: Preferences / Test Frameworks / Use Composer Autoloader
#echo PHPStorm+PHPUnit: Path to script: /opt/project/vendor/autoload.php
