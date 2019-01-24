CONFIG_FILE=~/.spoon/config.json

get_config() {
    jq_expression="$1"
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo '{}' > $CONFIG_FILE
    fi
    if ! $(jq . "$CONFIG_FILE" >/dev/null); then
        echo "[spoon] Error: $CONFIG_FILE is not valid JSON" 1>&2
        exit 1
    fi
    jq "$jq_expression" "$CONFIG_FILE"
}
