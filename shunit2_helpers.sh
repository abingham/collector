
assert_equals_stdout() { assertEquals 'stdout' "$1" "`cat ${stdoutF}`"; }
assert_equals_stderr() { assertEquals 'stderr' "$1" "`cat ${stderrF}`"; }

assert_no_stdout() { assert_equals_stdout ""; }
assert_no_stderr() { assert_equals_stderr ""; }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

assert_stdout_includes()
{
  local stdout="`cat ${stdoutF}`"
  if [[ "${stdout}" != *"${1}"* ]]; then
    fail "expected stdout to include ${1}"
  fi
}

refute_stdout_includes()
{
  local stdout="`cat ${stdoutF}`"
  if [[ "${stdout}" = *"${1}"* ]]; then
    fail "did not expect stdout to include ${1}"
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
