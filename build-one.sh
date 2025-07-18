#!/bin/bash

DOCKER_REGISTRY=

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
   echo "version....: "$(printf '%s | ' "${SUPPORTED_PHP_VERSIONS[@]}")" (default: ${DEFAULT_PHP_VERSION})"
   echo "binary-type: cli | apache  (default: cli)"
   echo "debug-type.: debug | nodebug  (default: debug)"
   echo "docker-tag.: a tag as used in Docker registry"
}

# if no PHP version is specified then we will use the default PHP version
if [ -z "${PARAM_PHP_VERSION}" ]; then
  PHP_VERSION=${DEFAULT_PHP_VERSION}
elif [[ " ${SUPPORTED_PHP_VERSIONS[*]} " = *"${PARAM_PHP_VERSION}"* ]]; then
  PHP_VERSION="${PARAM_PHP_VERSION}"
else
   echo "${ERROR_PREFIX} Unknown parameter #1 [version]: ${PARAM_PHP_VERSION}"
   echoSyntax
   exit
fi
echo "Building for PHP ${PHP_VERSION}..."


# With PHP 5.6 we will ignore updates
if [ "5.6" = "${PHP_VERSION}" ]; then
  IGNORE_UPDATES=true
else
  IGNORE_UPDATES=false
fi

# if no binary type is specified then we will use the default binary type
if [ -z "${PARAM_BINARY_TYPE}" ]; then
   BINARY_TYPE=${DEFAULT_BINARY_TYPE}
elif [[ " ${SUPPORTED_BINARY_TYPES[*]} " = *"${PARAM_BINARY_TYPE}"* ]]; then
   BINARY_TYPE="${PARAM_BINARY_TYPE}"
else
   echo "${ERROR_PREFIX} Unknown parameter #2 [binary-type]: ${PARAM_BINARY_TYPE}"
   echoSyntax
   exit
fi
echo "Building binary type '${BINARY_TYPE}'..."

# if no debug type is specified then we will use the default debug type
if [ -z "${PARAM_DEBUG_TYPE}" ]; then
  DEBUG_TYPE=${DEFAULT_DEBUG_TYPE}
elif [[ " ${SUPPORTED_DEBUG_TYPES[*]} " = *"${PARAM_DEBUG_TYPE}"* ]]; then
  DEBUG_TYPE="${PARAM_DEBUG_TYPE}"
else
   echo "${ERROR_PREFIX} Unknown parameter #3 [debug-type]: ${PARAM_DEBUG_TYPE}"
   echoSyntax
   exit
fi
echo "Building debug type '${DEBUG_TYPE}'..."

# if no docker tag is specified then we will use the default docker tag
if [ -z "${PARAM_DOCKER_TAG}" ]; then
  DOCKER_TAG=${DEFAULT_DOCKER_TAG}
else
  DOCKER_TAG=${PARAM_DOCKER_TAG}
fi
echo "Building with docker tag '${DOCKER_TAG}'..."

# detect dir of script
DIR=$(cd "$(dirname "${0}")" || exit; pwd)
cd "${DIR}" || exit

# load config
source "${DIR}/config/build.cfg.sh"
DOCKER_IMAGE="iomywiab-php-${PHP_VERSION}-${BINARY_TYPE}-${DEBUG_TYPE}"
IMAGE="${DOCKER_REGISTRY}${DOCKER_IMAGE}:${DOCKER_TAG}"

# create empty temp dir which will be our Docker context
rm -rf "${DIR}/temp/docker"
mkdir -p "${DIR}/temp/docker"

# parse template
cat "${DIR}/config/Dockerfile-${BINARY_TYPE}-${DEBUG_TYPE}.tpl" \
   | sed "s/\${PHP_VERSION}/${PHP_VERSION}/g" \
   | sed "s/\${REDIS_VERSION}/${REDIS_VERSION}/g" \
   | sed "s/\${XDEBUG_VERSION}/${XDEBUG_VERSION}/g" \
   | sed "s/\${XDEBUG_CONNECT}/${XDEBUG_CONNECT}/g" \
   | sed "s/\${XDEBUG_MODE}/${XDEBUG_MODE}/g" \
   | sed "s/\${XDEBUG_PORT}/${XDEBUG_PORT}/g" \
   | sed "s/\${XDEBUG_CLIENT_HOST}/${XDEBUG_CLIENT_HOST}/g" \
   | sed "s/\${XDEBUG_START_WITH_REQUEST}/${XDEBUG_START_WITH_REQUEST}/g" \
   | sed "s/\${ERROR_REPORTING}/${ERROR_REPORTING}/g" \
   | sed "s/\${BASE_VERSION}/${BASE_VERSION}/g" \
   > "${DIR}/temp/docker/Dockerfile"

#ssh-keyscan -t ed25519 bitbucket.org >> "${DIR}/temp/docker/known_hosts"

echo "Building image [${IMAGE}] (using buildx)..."
pushd "${DIR}/temp/docker/" || exit

if [ -z "${DOCKER_REGISTRY}" ]; then
  PUSH=""
else
  PUSH=" --push"
fi

docker buildx build ${PUSH} --tag "${IMAGE}" --platform=darwin/amd64,darwin/arm64,linux/amd64,linux/amd64/v2,linux/arm64,linux/arm/v7,linux/arm/v6 .

if [ ! -z "${DOCKER_REGISTRY}" ]; then
   docker pull "${IMAGE}"
fi

popd || exit
echo "Building image [${IMAGE}] (using buildx): done."


echo --start-of-result------------------------------------------------------------------------

#docker run --rm --name "${DOCKER_IMAGE}" -it "${DOCKER_IMAGE}" /etc/redis/redis.conf | grep supervised
#docker run --rm --name "${DOCKER_IMAGE}" -it "${DOCKER_IMAGE}" systemctl status redis
#docker run --rm --name "${DOCKER_IMAGE}" -it "${DOCKER_IMAGE}" hostname -f
#docker run --rm --name "${DOCKER_IMAGE}" -it "${IMAGE}" cat /etc/os-release | grep PRETTY_NAME
#docker run --rm --name "${DOCKER_IMAGE}" -it "${DOCKER_IMAGE}" lsb_release -a
#docker run --rm --name "${DOCKER_IMAGE}" -it "${DOCKER_IMAGE}" hostnamectl
#docker run --rm --name "${DOCKER_IMAGE}" -it "${IMAGE}" uname -r
docker run --rm --name "${DOCKER_IMAGE}" -it "${IMAGE}" php --version
#echo "Docker:/root/.ssh/"#docker run --rm --name "${DOCKER_IMAGE}_build" -it "${DOCKER_IMAGE}" ls -lh /root/.ssh/
#echo "Localhost:${TEMP_SSH_DIR}";ls -lh "${TEMP_SSH_DIR}"
#docker run --rm --name "${DOCKER_IMAGE}" -it "${DOCKER_IMAGE}" ssh -T git@github.com
#docker run --rm --name "${DOCKER_IMAGE}" -it "${DOCKER_IMAGE}" ls -lh /usr/local/etc/php/conf.d/
docker run --rm --name "${DOCKER_IMAGE}" -it "${DOCKER_IMAGE}" cat /usr/local/etc/php/conf.d/iomywiab-php.ini
#docker run --rm --name "${DOCKER_IMAGE}" -it "${DOCKER_IMAGE}" cat /usr/local/etc/php/php.ini
echo --end-of-result--------------------------------------------------------------------------

#docker container prune
#rm -rf "${TEMP_SSH_DIR}"
