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
