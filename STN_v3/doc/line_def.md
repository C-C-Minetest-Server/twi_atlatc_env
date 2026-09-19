# Defining an STN_v3 line

`STN_v3/src/02-config-lines.lua` defines the lines understood by the station
and passenger-information systems. A line definition has two jobs:

* identify which trains belong to the line; and
* describe the ordered stopping points, dwell times, displays, and optional
  timetable or through-running behavior.

This document describes the configuration consumed by `F.stn_v3`. It assumes
that the station and platform tracks have already been registered as described
in [`first_line.md`](first_line.md). The station-track program and the line
definition must use the same complete stopping-point ID:

```text
station_id:track_id:point_id
```

For example, a LuaATC track configured with `station_id = "ALP"`,
`track_id = "1"`, and `point_id = "N1"` is represented in the line as
`["ALP:1:N1"]`.

## Minimal operational shape

The following is the smallest useful two-station shuttle. It has one entry for
each stopping point and closes the route by pointing the last `next` field back
to the first point.

```lua
F.stn_v3_lines["AB1"] = {
	rc = "L-AB1",
	code = "AB1",
	name = { "Alpha-Bravo Shuttle", "AB1" },
	termini = {
		N = "ALP",
		S = "BRA",
	},
	stations = {
		["ALP:1:N1"] = {
			delay = 10,
			reverse = true,
			next = "BRA:1:S1",
			dir = "S",
		},
		["BRA:1:S1"] = {
			delay = 10,
			reverse = true,
			next = "ALP:1:N1",
			dir = "N",
		},
	},
}
```

`F.stn_v3_lines` is a table indexed by an internal line ID. The key (`AB1` in
the example) is also used by train-tracking and must be unique in the loaded
configuration.

## Line-level fields

| Field | Type | Required? | Purpose |
| --- | --- | --- | --- |
| `rc` | string | One of `rc` or `line` for operational service | Route code used to match a train, for example `L-AB1`. The train must contain this code in its route-code list. |
| `line` | string | One of `line` or `rc` for operational service | Alternative train matcher. The train's Advtrains line must equal this value. Do not normally set both. |
| `code` | string | No, but recommended | Short public line code sent to PIS. It falls back to the internal line ID if omitted. |
| `name` | string or table of strings | No, but recommended | Public line name sent to displays. A table should list the longest form first; the display helper selects a form that fits. It falls back to the internal line ID. |
| `color` | display color value | No | Line color forwarded to PIS. The exact interpretation is made by PIS_v3. |
| `background_color` | display color value | No | Background color forwarded to PIS. |
| `termini` | table, direction string to station ID | Yes for active service | Maps each `dir` value used by a station to the station shown as the destination, such as `{ N = "ALP", S = "BRA" }`. Active display and arrival code indexes this table, so every operational direction needs an entry. |
| `no_to_prefix` | boolean | No | When true, suppresses the normal `Terminus: ` or `To: ` style prefix on supported displays. Used by the loop lines in this repository. |
| `stations` | table of stopping-point definitions | Yes for an operational line | Maps full stopping-point IDs to station definitions. Display-only line entries may omit it, but trains cannot stop on such a line. |

`rc` and `line` are alternatives, not fields that must both be present. A
display-only entry can contain only `code` and `name`; it is not eligible for
train matching and must not be used by a `F.stn_v3` platform expecting an
operational route.

### Direction and terminus values

`dir` is an application-defined string, not necessarily a compass direction.
Common values are `N`, `S`, `E`, and `W`; loop services in this repository use
`CW` and `ACW`. The value must be accepted by `termini`, otherwise displays
cannot resolve the destination. A station definition may also provide a
function for `dir` when the direction must be selected dynamically.

## Stopping-point fields

Each value in `stations` is normally a table. The key identifies the physical
LuaATC stopping point; it is not just a station ID.

| Field | Type | Required? | Purpose |
| --- | --- | --- | --- |
| `next` | string | Yes for a normal operational stop | Full stopping-point ID of the next stop. The train is registered against this point after departure, and arrival estimates follow this link. The final point in a loop points back to the first. |
| `dir` | string or function | Yes | Direction code for destination displays and PIS. A function receives the train and must return a direction string present in `termini`. |
| `delay` | number, seconds | No | Base dwell time before departure. The station code defaults to 10 seconds when no schedule is present. |
| `reverse` | boolean | No | If true, sends the train a reverse command before it leaves. Use at termini; omit or set false for a through stop. |
| `depint` | RWT duration string | Only with `depoff` for scheduled departures | Repeating departure interval in `cc;hh;mm;ss` form, for example `00;00;06;00` for six minutes. |
| `depoff` | RWT duration string | Only with `depint` for scheduled departures | Offset of the departure pattern, in the same format. The door-close time is rounded up to the next occurrence of this pattern after the train arrives plus its dwell time. |
| `on_leave_rc` | string | No | Space-separated route codes appended when the train leaves. This is where interlocking-specific `J-`, `B-`, and `K-STN-CLEAR-ROUTE` codes are commonly added. It does not create routes by itself. |
| `through_run_to` | string | No | Internal ID of another line to use after this stop. The destination must exist in the target line's `stations` table. STN_v3 swaps the train's matcher and continues using this line's route definition. |
| `via_dest` | boolean | No | Marks this stop as a via destination in the PIS batch. Stops before it in the same direction can display this station as “via”. |
| `via_override` | string | No | Station ID whose registered name should be used as the via destination instead of the current stopping point. |
| `kick` | boolean | No | Adds the kick-out command when the train arrives. Use only when the platform's route priority requires it. |

The schedule fields are a pair. If either `depint` or `depoff` is missing,
STN_v3 uses `delay` directly. RWT duration strings use centiseconds,
`hours`, `minutes`, and `seconds` in the repository's `cc;hh;mm;ss` notation;
copy the format used in the examples rather than writing `6m`.

## Scheduled service

To make a shuttle leave on a repeating pattern, put `depint` and `depoff` on
each departure point. The offset is measured within the repeating interval.
For a six-minute service with Alpha departures at `:00` and Bravo departures
at `:03`:

```lua
F.stn_v3_lines["AB1"] = {
	rc = "L-AB1",
	code = "AB1",
	name = { "Alpha-Bravo Shuttle", "AB1" },
	termini = { N = "ALP", S = "BRA" },
	stations = {
		["ALP:1:N1"] = {
			delay = 10,
			depint = "00;00;06;00",
			depoff = "00;00;00;00",
			reverse = true,
			next = "BRA:1:S1",
			dir = "S",
		},
		["BRA:1:S1"] = {
			delay = 10,
			depint = "00;00;06;00",
			depoff = "00;00;03;00",
			reverse = true,
			next = "ALP:1:N1",
			dir = "N",
		},
	},
}
```

The interval does not itself launch trains or enforce a fleet size. It tells
the station system when an already-arrived train may close its doors and
depart. Physical dispatch, route setting, and the number of trains remain the
responsibility of the surrounding Advtrains/LuaATC setup.

## Branching service

A branch is represented by multiple possible station definitions, usually by
making the definition at the split a function. The function receives
`(train, arrival_time, estimated)` and returns the station table to use.

The following pattern sends a train from `JCT` to either `NORTH` or `SOUTH`.
The branch decision must be deterministic for a given train and arrival; the
example uses a placeholder `choose_branch` function to keep the route model
clear.

```lua
local north = {
	dir = "N",
	delay = 10,
	reverse = true,
	next = "NORTH:1:N1",
}

local south = {
	dir = "S",
	delay = 10,
	reverse = true,
	next = "SOUTH:1:S1",
}

F.stn_v3_lines["BR1"] = {
	rc = "L-BR1",
	code = "BR1",
	name = { "Branch Line", "BR1" },
	termini = { N = "NORTH", S = "SOUTH", C = "JCT" },
	stations = {
		["JCT:1:E1"] = function(train, arrival_time, estimated)
			if estimated and not choose_branch(train, arrival_time) then
				return nil
			end
			return choose_branch(train, arrival_time) and north or south
		end,
		["NORTH:1:N1"] = {
			dir = "C", delay = 10, reverse = true,
			next = "JCT:1:W1",
		},
		["SOUTH:1:S1"] = {
			dir = "C", delay = 10, reverse = true,
			next = "JCT:1:W1",
		},
		["JCT:1:W1"] = {
			dir = "C", delay = 10, reverse = false,
			next = "JCT:1:E1",
		},
	},
}
```

In a real configuration, the branch table normally includes a separate
stopping-point path for each branch and a return path that reconnects them.
The function may return `nil` during estimation to say that a service is not
currently expected; the PIS estimator then stops extending that prediction.
The function must return a table during an actual arrival, and that table must
contain at least `dir` and `next`.

For a branch that is selected by timetable rather than Lua, an alternative is
to define separate line IDs and match their trains with different `rc` values.
That is simpler to operate when the branches have independent fleets.

## Through-running services

Through-running joins two line definitions at a platform. The train arrives
under one line ID, then changes to another line ID when it leaves. Put
`through_run_to` on the stopping point where the identity changes, and make
sure the target line contains the `next` stopping point.

```lua
F.stn_v3_lines["ISL"] = {
	rc = "L-ISL",
	code = "ISL",
	name = { "Islands Line", "ISL" },
	termini = { E = "ACP", W = "SPN" },
	stations = {
		["SPN:3:W1"] = {
			dir = "E", delay = 5, reverse = true,
			next = "ISN:1:E1",
		},
		["ISN:1:E1"] = {
			dir = "E", delay = 10,
			through_run_to = "CEN",
			next = "ACP:1:E1",
		},
		["SCL:2:W1"] = {
			dir = "W", delay = 10,
			next = "ISN:2:W1",
		},
	},
}

F.stn_v3_lines["CEN"] = {
	rc = "L-CEN",
	code = "CEN",
	name = { "Central Line", "CEN" },
	termini = { E = "ACP", W = "SPN" },
	stations = {
		["ACP:1:E1"] = {
			dir = "W", delay = 10, reverse = true,
			through_run_to = "ISL",
			next = "SCL:2:W1",
		},
	},
}
```

At `ACP:1:E1`, STN_v3 swaps the train from `CEN` to `ISL` and validates that
`SCL:2:W1` is present in `ISL.stations`. The target line must have its own
`rc` or `line` matcher so the route swap can assign it. Both line definitions
should describe the display identity passengers should see on their respective
sections of the trip.

Do not use `through_run_to` merely to describe a train passing through a
station. A normal through stop has `reverse = false` and a regular `next`.
`through_run_to` specifically changes the line definition and train matcher.

## Dynamic definitions and branching schedules

Any station value may be a function instead of a table. STN_v3 calls it as:

```lua
station_def(train, arrival_time, estimated)
```

For a real arrival, `arrival_time` is the current RWT time and `estimated` is
false. During PIS prediction, `arrival_time` is the estimated time and
`estimated` is true. The function must return a station table for an actual
arrival. It may return `nil` during estimation when the service should not yet
be shown. A function is useful for selecting a branch, changing direction, or
choosing a departure interval based on the train or time.

The returned table is copied before use, so changing it at one arrival does
not mutate the shared line definition. The returned `dir` may itself be a
function; it receives the train and must return a string accepted by
`termini`.

## Route-control fields

`on_leave_rc` is deliberately just a string passed to Advtrains as additional
route codes. STN_v3 does not parse or validate the interlocking commands in
that string. Existing configurations commonly use:

```lua
on_leave_rc = "B-ALP-T1N K-STN-CLEAR-ROUTE",
```

Use the route-control conventions of the railway. The `K-STN-CLEAR-ROUTE`
code causes the next station arrival to remove temporary `S-`, `SN-`, `J-`,
`Y-`, and `B-` codes. Route-control mistakes can prevent a train from stopping 
at the next station even when the line definition itself is valid.

## Validation checklist

Before reloading the generated environment, check:

1. Every operational line has `rc` or `line`, `termini`, and `stations`.
2. Every `stations` key exactly matches a programmed `F.stn_v3` track.
3. Every `next` value is another valid stopping-point key in the current line,
   or in the target line named by `through_run_to`.
4. Every `dir` value has a corresponding `termini` entry.
5. `depint` and `depoff` are either both present or both absent.
6. A terminus has `reverse = true` unless the physical route reverses by some
   other mechanism; an ordinary through stop normally has it omitted or false.
7. Branch functions return a complete station table on actual arrival.
8. Through-running target lines have a matcher and contain the hand-off
   destination.

After rebuilding, test one train manually in each direction. Confirm the
external display's line and next-stop text, the internal display's destination,
the scheduled departure time (if used), and the route after each reversal or
line hand-off.
