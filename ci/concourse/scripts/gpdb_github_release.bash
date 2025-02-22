#!/usr/bin/env bash
# Copyright (C) 2019-Present Pivotal Software, Inc. All rights reserved.
# This program and the accompanying materials are made available under the
# terms of the under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain a
# copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

set -euo pipefail

apk update && apk add --no-progress git

BASE_DIR="$(pwd)"

GPDB_RELEASE_COMMIT_SHA="$(cat gpdb_src/.git/ref)"
GPDB_RELEASE_TAG="$(git --git-dir gpdb_src/.git describe --tags "${GPDB_RELEASE_COMMIT_SHA}")"

function build_gpdb_binaries_tarball() {
	pushd "${BASE_DIR}/gpdb_src"
	git --no-pager show --summary refs/tags/"${GPDB_RELEASE_TAG}"

	git archive -o "${BASE_DIR}/release_artifacts/${GPDB_RELEASE_TAG}.tar.gz" --prefix="gpdb-${GPDB_RELEASE_TAG}/" --format=tar.gz refs/tags/"${GPDB_RELEASE_TAG}"
	git archive -o "${BASE_DIR}/release_artifacts/${GPDB_RELEASE_TAG}.zip" --prefix="gpdb-${GPDB_RELEASE_TAG}/" --format=zip -9 refs/tags/"${GPDB_RELEASE_TAG}"
	popd
	echo "Created the release binaries successfully! [tar.gz, zip]"
}

function create_github_release_metadata() {
	# Prepare for the gpdb github release
	echo "${GPDB_RELEASE_TAG}" >"release_artifacts/name"
	echo "${GPDB_RELEASE_TAG}" >"release_artifacts/tag"
	echo "Greenplum-db version: ${GPDB_RELEASE_TAG}" >"release_artifacts/body"
	echo "${GPDB_RELEASE_COMMIT_SHA}" >release_artifacts/commitish
}

function _main() {
	echo "Current Released Tag: ${GPDB_RELEASE_TAG}"

	build_gpdb_binaries_tarball
	create_github_release_metadata
}

_main
