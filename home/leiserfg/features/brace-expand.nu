# ==============================================================================
# Brace Expansion Module for Nushell
# ==============================================================================
#
# This module provides interactive brace expansion functionality for the Nushell
# command line. It wraps the token under the cursor with Nushell's `str expand`
# command, enabling quick expansion of brace patterns like `{a,b,c}` or `file{1..5}.txt`.
#
# Features:
#   - Tokenizes command line while respecting quotes and escape sequences
#   - Detects the token at or before the cursor position
#   - Wraps the token with `...("token" | str expand)` for expansion
#   - Preserves cursor position relative to the token
#
# Keybinding:
#   Ctrl+E - Expand braces on the token at cursor (works in emacs, vi_insert, vi_normal)
#
# Example:
#   file{1,2,3}.txt  →  ...("file{1,2,3}.txt" | str expand)
#
# Only exports `expand-brace-at-cursor`, all helper functions are private.
# ==============================================================================

module brace-expand {
    # Tokenize a string into tokens with their positions
    # Handles quoted strings and escaped characters
    def tokenize-with-positions [line: string]: nothing -> list<record<token: string, start: int, end: int>> {
        let chars = $line | split chars
        let len = $chars | length

        mut tokens = []
        mut current_token = ""
        mut token_start = -1
        mut in_quote = ""
        mut escaped = false
        mut i = 0

        while $i < $len {
            let char = $chars | get $i

            if $escaped {
                $current_token ++= $char
                $escaped = false
            } else if $char == '\\' {
                if $token_start == -1 {
                    $token_start = $i
                }
                $current_token ++= $char
                $escaped = true
            } else if $char == '"' or $char == "'" {
                if $in_quote == "" {
                    # entering quote
                    if $token_start == -1 {
                        $token_start = $i
                    }
                    $current_token ++= $char
                    $in_quote = $char
                } else if $in_quote == $char {
                    # exiting quote
                    $current_token ++= $char
                    $in_quote = ""
                } else {
                    # different quote type, treat as literal
                    $current_token ++= $char
                }
            } else if $char =~ '^\s$' and $in_quote == "" {
                # whitespace outside quotes - end token
                if $token_start != -1 {
                    $tokens ++= [{token: $current_token, start: $token_start, end: $i}]
                    $current_token = ""
                    $token_start = -1
                }
            } else {
                # regular character
                if $token_start == -1 {
                    $token_start = $i
                }
                $current_token ++= $char
            }

            $i += 1
        }

        # handle final token
        if $token_start != -1 {
            $tokens ++= [{token: $current_token, start: $token_start, end: $len}]
        }

        $tokens
    }

    # Find which token the cursor is in, or the token to the left if between tokens
    # Returns record with index, token, start, end or null
    def find-token-at-cursor [tokens: list<record<token: string, start: int, end: int>>, cursor: int]: nothing -> record<index: int, token: string, start: int, end: int, cursor_inside: bool> {
        # First check if cursor is inside a token
        let inside = $tokens | enumerate | where { |it|
            $cursor >= $it.item.start and $cursor <= $it.item.end
        }
        if not ($inside | is-empty) {
            let m = $inside | first
            return {index: $m.index, token: $m.item.token, start: $m.item.start, end: $m.item.end, cursor_inside: true}
        }

        # Cursor is not inside a token, find the token to the left
        let left = $tokens | enumerate | where { |it|
            $it.item.end <= $cursor
        }
        if ($left | is-empty) {
            null
        } else {
            let m = $left | last
            {index: $m.index, token: $m.item.token, start: $m.item.start, end: $m.item.end, cursor_inside: false}
        }
    }

    # Wrap a token for brace expansion
    # If already quoted, use the existing quotes
    def wrap-token-for-expansion [token: string]: nothing -> string {
        if ($token | str starts-with '"') and ($token | str ends-with '"') {
            # Already double-quoted, use as-is
            ['...(' $token ' | str expand)'] | str join
        } else if ($token | str starts-with "'") and ($token | str ends-with "'") {
            # Already single-quoted, use as-is
            ['...(' $token ' | str expand)'] | str join
        } else {
            # Not quoted, add double quotes
            ['...("' $token '" | str expand)'] | str join
        }
    }

    # Replace a token in the line given start/end positions
    def replace-token-in-line [line: string, start: int, end: int, replacement: string]: nothing -> string {
        let before = $line | str substring 0..<$start
        let after = $line | str substring $end..
        $"($before)($replacement)($after)"
    }

    # Main function: expand brace at cursor position
    # For testing, accepts line and cursor as parameters
    def expand-brace-in-line [line: string, cursor: int]: nothing -> record<line: string, cursor: int> {
        let tokens = tokenize-with-positions $line
        let found = find-token-at-cursor $tokens $cursor

        if $found == null {
            return {line: $line, cursor: $cursor}
        }

        let wrapped = wrap-token-for-expansion $found.token
        let new_line = replace-token-in-line $line $found.start $found.end $wrapped

        # Calculate prefix length before the token content
        # ...(" = 5 chars, or ...( = 4 chars if already quoted
        let prefix_len = if ($found.token | str starts-with '"') or ($found.token | str starts-with "'") {
            4  # ...(
        } else {
            5  # ...("
        }

        # Calculate new cursor position
        let new_cursor = if $found.cursor_inside {
            # Cursor was inside token - keep same relative position
            let cursor_offset = $cursor - $found.start
            $found.start + $prefix_len + $cursor_offset
        } else {
            # Cursor was outside token - place at end of the token content inside the expansion
            # prefix_len + token length
            $found.start + $prefix_len + ($found.token | str length)
        }

        {line: $new_line, cursor: $new_cursor}
    }

    # The actual command that interacts with commandline
    export def expand-brace-at-cursor []: nothing -> nothing {
        let line = commandline
        let cursor = commandline get-cursor

        let result = expand-brace-in-line $line $cursor

        commandline edit --replace $result.line
        commandline set-cursor $result.cursor
    }
}

use brace-expand expand-brace-at-cursor

# Bind Ctrl+E to expand braces
$env.config.keybindings ++= [{
    name: expand_braces
    modifier: control
    keycode: char_e
    mode: [emacs vi_insert vi_normal]
    event: {
        send: executehostcommand
        cmd: "expand-brace-at-cursor"
    }
}]
