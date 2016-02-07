# New Relic

## Description

Install the New Relic server agent on Ubuntu/Debian.

N.B. If this role is used with an invalid licence key, the agent will
terminate itself and lead to a failure when running ansible.

## Variables

| Variable         | Type | Required | Description                                  |
| -------------    | ---  | -------- | -------------                                |
| newrelic_license | str  | yes      | New Rewlic license key. (40 characters long) |


## Dependencies

None
