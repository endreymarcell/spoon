# Fail and display details if the expected and actual values do not
# equal. Details include both values.
#
# Globals:
#   none
# Arguments:
#   $1 - actual value
#   $2 - expected value
# Returns:
#   0 - values equal
#   1 - otherwise
# Outputs:
#   STDERR - details, on failure
assert_equal_regex() {
  if [[ ! $1 =~ "$2" ]]; then
    batslib_print_kv_single_or_multi 8 \
        'pattern' "$2" \
        'string'  "$1" \
      | batslib_decorate 'regex does not match' \
      | fail
  fi
}


# Fail and display details if the called function returns
# with anything else than 0.
#
# Globals:
#   none
# Arguments:
#   $* - the function call
# Returns:
#   0 - function succeeded
#   1 - function failed
# Outputs:
#   STDERR - details, on failure
assert_function_success() {
  if ! $("$@" >/dev/null 2>&1); then
    batslib_print_kv_single_or_multi 8 \
        'function' "$1" \
        'args' "${*:2}" \
      | batslib_decorate 'function falied' \
      | fail
  fi
}


# Fail and display details if the called function returns
# with 0.
#
# Globals:
#   none
# Arguments:
#   $* - the function call
# Returns:
#   0 - function failed
#   1 - function succeeded
# Outputs:
#   STDERR - details, on failure
assert_function_failure() {
  if $("$@" >/dev/null 2>&1); then
    batslib_print_kv_single_or_multi 8 \
        'function' "$1" \
        'args' "${*:2}" \
      | batslib_decorate 'function succeeded' \
      | fail
  fi
}
