DOCKER=docker

TAG=gh-pages

# Build the docker image
image:
	${DOCKER} build -t ${TAG} .
image_alpine:
	${DOCKER} build -t ${TAG} . -f Dockerfile.alpine

VERSION := $(shell ruby -r./lib/github-pages/version.rb -e "puts GitHubPages::VERSION")
publish_alpine:
	${DOCKER} buildx build -f Dockerfile.alpine --platform linux/amd64,linux/arm64 -t markcrossfield/pages-gem:${VERSION}-alpine -t markcrossfield/pages-gem:latest-alpine --push .

# Produce a bash shell
shell:
	${DOCKER} run --rm -it \
		-p 4000:4000 \
		-u `id -u`:`id -g` \
		-v ${PWD}:/src/gh/pages-gem \
		${TAG} \
		/bin/bash

# Spawn a server. Specify the path to the SITE directory by
# exposing it using `export SITE="../path-to-jekyll-site"` prior to calling or
# by prepending it to the make rule e.g.: `SITE=../path-to-site make server`
server:
	test -d "${SITE}" || \
		(echo -E "specify SITE e.g.: SITE=/path/to/site make server"; exit 1) && \
	${DOCKER} run --rm -it \
		-p 4000:4000 \
		-u `id -u`:`id -g` \
		-v ${PWD}:/src/gh/pages-gem \
		-v `realpath ${SITE}`:/src/site \
		-w /src/site \
		${TAG}

.PHONY:
	image image_alpine server shell
