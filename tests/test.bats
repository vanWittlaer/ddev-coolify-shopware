setup() {
  set -eu -o pipefail
  export DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)/.."
  export TESTDIR=~/tmp/test-coolify-bootstrap
  mkdir -p $TESTDIR
  export PROJNAME=test-coolify-bootstrap
  export DDEV_NONINTERACTIVE=true
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1 || true
  cd "${TESTDIR}"
  ddev config --project-name=${PROJNAME} --project-type=php --docroot=public --create-docroot
  ddev start -y >/dev/null
}

health_checks() {
  # OpenTofu baked into the web container by web-build/Dockerfile.opentofu
  ddev exec "tofu version" | grep "OpenTofu"

  # Command is registered and self-documents all three actions
  ddev coolify-bootstrap --help | grep "Usage: ddev coolify-bootstrap \[init|up|destroy\]"

  # init scaffolds infra/ with the pinned tcss ref substituted
  ddev coolify-bootstrap init
  [ -f ${TESTDIR}/infra/main.tf ]
  [ -f ${TESTDIR}/infra/.gitignore ]
  [ -f ${TESTDIR}/infra/production.tfvars ]
  [ -f ${TESTDIR}/infra/staging.tfvars ]
  [ -f ${TESTDIR}/infra/secrets.auto.tfvars.example ]
  grep -q "ref=v0" ${TESTDIR}/infra/main.tf
  ! grep -q "__TCSS_VERSION__" ${TESTDIR}/infra/main.tf

  # Second init refuses (scaffold is fresh-projects-only)
  run ddev coolify-bootstrap init
  [ "$status" -ne 0 ]

  # up without secrets fails fast with the actionable hint (never reaches tofu/plan)
  run ddev coolify-bootstrap up
  [ "$status" -ne 0 ]
  [[ "$output" == *"secrets.auto.tfvars is missing"* ]]
}

teardown() {
  set -eu -o pipefail
  ddev delete -Oy ${PROJNAME} >/dev/null 2>&1
  [ "${TESTDIR}" != "" ] && rm -rf ${TESTDIR}
}

@test "install from directory" {
  set -eu -o pipefail
  cd ${TESTDIR}
  echo "# ddev add-on get ${DIR} with project ${PROJNAME} in ${TESTDIR} ($(pwd))" >&3
  ddev add-on get ${DIR}
  ddev restart -y >/dev/null
  health_checks
}
