#!/bin/bash

assert_equals_stdout()
{
  stdout=$(cat ${stdoutF})
  assertEquals 'stdout' "${1}" "${stdout}"
}

assert_equals_stderr()
{
  stderr=$(cat ${stderrF})
  assertEquals 'stderr' "${1}" "${stderr}"
}

assert_no_stdout() { assert_equals_stdout ""; }
assert_no_stderr() { assert_equals_stderr ""; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assert_stdout_includes()
{
  stdout=$(cat ${stdoutF})
  if ! echo ${stdout} | egrep -q -- "${1}"; then
    echo "expected stdout to include ${1}"
    echo "<stdout>"
    echo "${stdout}"
    echo "</stdout>"
    fail
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

refute_stdout_includes()
{
  stdout=$(cat ${stdoutF})
  if echo ${stdout} | egrep -q -- "${1}"; then
    echo "did not expect stdout to include ${1}"
    echo "<stdout>"
    echo "${stdout}"
    echo "</stdout>"
    fail
  fi
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

oneTimeSetUp()
{
  outputDir="${SHUNIT_TMPDIR}/output"
  mkdir "${outputDir}"
  stdoutF="${outputDir}/stdout"
  stderrF="${outputDir}/stderr"
  mkdirCmd='mkdir'  # save command name in variable to make future changes easy
  testDir="${SHUNIT_TMPDIR}/some_test_dir"
}
