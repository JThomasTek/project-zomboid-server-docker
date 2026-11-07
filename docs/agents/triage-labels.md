# Triage Labels

The skills speak in terms of five canonical triage roles. This file maps those roles to the actual label strings used in this repo's issue tracker.

| Label in mattpocock/skills | Label in our tracker | Meaning                                  |
| -------------------------- | -------------------- | ---------------------------------------- |
| `needs-triage`             | `needs-triage`       | Maintainer needs to evaluate this issue  |
| `needs-info`               | `needs-info`         | Waiting on reporter for more information |
| `ready-for-agent`          | `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`    | Requires human implementation            |
| `wontfix`                  | `wontfix`            | Will not be actioned                     |

## Wayfinder labels

Used by `/wayfinder` for planning large efforts as decision maps.

| Label | Meaning |
| ------ | ------- |
| `wayfinder:map` | A wayfinder planning map issue |
| `wayfinder:research` | A research ticket (AFK) |
| `wayfinder:prototype` | A prototype ticket (HITL) |
| `wayfinder:grilling` | A grilling/conversation ticket (HITL) |
| `wayfinder:task` | A manual task ticket (HITL or AFK) |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from this table.