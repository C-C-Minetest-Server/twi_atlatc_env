# Setting up a railway line from scratch

This document walks you through creating a brand-new railway line on a
Luanti/Minetest instance that already has **STN_v3** and **PIS_v3** installed
(along with the [Advanced Trains] modpack and 1F616EMO's fork of Digiscreen).

You will end up with:

* A handful of platform tracks that the station system knows about
* A new station registered in `01-config-station.lua`
* A new line and a route registered in `02-config-line.lua`
* A working train that announces itself on the platform displays

The walkthrough uses a small **two-station shuttle** as the example. The
general procedure is the same for any line — extend it with more stations,
`on_leave_rc` strings, and per-station timing.

[Advanced Trains]: https://content.luanti.org/packages/orwell/advtrains/

## 0. Prerequisites

Before you start, make sure that:

1. PIS_v3 and STN_v3 are installed. Follow the setup in
   `PIS_v3/doc/initial_setup.md` first; the very last paragraph of that
   document points you to STN_v3.
2. You have the `atlatc` and `track_builder` privileges in-game.
3. You have a working LuaATC development loop — i.e. you can rebuild
   `STN_v3/env_setup.lua`, re-paste it into the LuaATC environment, and re-run
   the init code without restarting the server. See "Rebuilding STN_v3" below.
4. You have read the relevant STN_v3 source files, in particular
   `src/35-station-tracks.lua` (defines `F.stn_v3`), `src/01-config-station.lua`
   (station names) and `src/02-config-line.lua` (lines and routes).

The example below assumes you have two stations called **"Alpha"** and
**"Bravo"**, with one platform each (`1` and `1`), and you want a shuttle
line `AB1` that runs back and forth between them on a 6-minute headway.

Substitute your own station/track IDs as appropriate.

## 1. Laying the physical track

Lay the railway physically before touching any configuration. Use
`advtrains_luaautomation:oppanel` and the track-placement tools to build:

* Two platforms (one at Alpha, one at Bravo) — each platform is a stopping
  point on a single track.
* The mainline between them, with whatever junctions, signals, and
  passenger-platform arrows (`atc_pas_platform` or equivalent) you need.

You need at least one **LuaATC track** per platform — that is the node that
calls into `F.stn_v3` and is the "anchor" of the platform. It is the
`advtrains_luaautomation:track` block, not a plain `advtrains` track. Drop
one of those on the platform where you want the train to stop, oriented so
the train passes over it as it pulls in.

If the station is bidirectional, you typically need **two** LuaATC tracks per
platform — one for each direction of travel. The example below uses the
"northbound" track at each station; add a southbound companion if needed.

## 2. Adding station tracks that call F.stn_v3

Each LuaATC track on a platform must run a small LuaATC program that calls
`F.stn_v3` with three identifiers:

* `station_id` — the unique short code of the station. This is the same
  string you will register in `01-config-station.lua` (e.g. `ALP` for Alpha,
  `BRA` for Bravo).
* `track_id` — the platform/track identifier within the station. Use any
  short string; `1`, `2`, `A`, `B`, … are all fine. The full point identifier
  is built as `station_id:track_id:point_id` internally.
* `point_id` — distinguishes multiple LuaATC tracks on the same platform
  (for example, one for each direction). Use `N1`, `S1`, `W1`, `E1` etc. so
  the line configuration reads naturally later.

The minimum LuaATC program for a northbound track at Alpha is:

```lua
F.stn_v3({
    station_id = "ALP",
    track_id = "1",
    point_id = "N1",
})
```

For a southbound track at the same platform:

```lua
F.stn_v3({
    station_id = "ALP",
    track_id = "1",
    point_id = "S1",
})
```

A few extra parameters that `F.stn_v3` understands:

| Parameter   | Values            | Meaning                                                                                          |
| ----------- | ----------------- | ------------------------------------------------------------------------------------------------ |
| `door_dir`  | `"L"`, `"R"`, `"C"` | Which side the doors should open. `"C"` is the default ("closed").                  |
| `kick`      | boolean           | Force a kick-out of the platform even if a higher-priority route is set (see `F.stn_v3` source). |

The function will:

* On **approach**: warn the train that it is entering a known platform,
  disable ARS, and start tracking the train for PIS_v3.
* On **arrival**: open the doors, send the train data to the PIS, schedule
  the door-close, and queue the departure.
* On **departure**: clear certain route-control codes (if the train has
  `K-STN-CLEAR-ROUTE`) and release the train onto the next leg of its route.

If a train arrives at a `F.stn_v3` track that is not configured for any line,
or the line definition for the matching `station_id:track_id:point_id` is
missing, the in-cab text will read *"Station track misconfigured. Contact
railway operator."* That is your clue that step 3 or 4 is wrong.

## 3. Registering the station in 01-config-station.lua

Every station that the PIS or the line system needs to *name* must be
registered in `STN_v3/src/01-config-station.lua`. Open that file and add a
new entry to `F.station_names`. The key is the `station_id` you used in
step 2; the value is either a single string (the name), or a list of strings
from longest to shortest. The system picks the longest one that fits the
display.

For our two stations:

```lua
F.station_names = {
    -- ... existing entries ...

    -- My new shuttle
    ALP = {
        "Alpha Central",
        "Alpha",
    },
    BRA = {
        "Bravo Junction",
        "Bravo Jct.",
        "Bravo",
    },
}
```

The order matters: put the full name first, then progressively shorter
forms. The runner-up names are used for the on-train "Next: …" line and
on-platform displays when space is tight.

You generally do **not** need to add an entry to `F.station_interchange` —
that table is for stations where two or more lines cross. Skip it for now;
come back to it if you later add a second line that meets this one.

## 4. Defining the line in 02-config-line.lua

This is the bulk of the configuration. Open `STN_v3/src/02-config-line.lua`
and append a new line to `F.stn_v3_lines`. The line key is a free-form
identifier used internally (`AB1` here). Each value is a table with the
following shape:

```lua
F.stn_v3_lines["AB1"] = {
    -- 1. Train matching
    rc = "L-AB1",                    -- optional: only trains that have this
                                     -- route code (in their ad-hoc rc list)
                                     -- will be matched to this line at a
                                     -- F.stn_v3 track.

    -- 2. PIS display parameters
    code = "AB1",                    -- short line code, used on displays
    name = {                         -- name(s) of the line, longest first
        "Alpha–Bravo Shuttle",
        "Alpha–Bravo",
        "AB1",
    },
    -- optional: termini = { N = "ALP", S = "BRA" },  -- see below

    -- 3. The route itself: a doubly-linked list of stopping points
    stations = {
        -- The key is a point_id: station_id:track_id:point_id
        ["ALP:1:N1"] = {
            -- Timing: how long the doors stay open
            delay = 10,
            -- If true, the train reverses direction at this point
            reverse = true,

            -- Where to go next, and in which direction
            next = "BRA:1:S1",
            dir   = "S",             -- used to look up `termini[dir]`
                                     -- for "Heading to: …" displays

            -- Optional: an R-pattern departure interval (cc;hh;mm;ss).
            -- Together with `depoff`, this tells the door-close scheduler
            -- to wait for the next multiple of `depint` after `depoff`
            -- before closing the doors.
            depint = "00;00;06;00",  -- depart every 6 minutes
            depoff = "00;00;00;00",  -- offset 0 within the pattern

            -- Optional: extra route-control codes added to the train's
            -- rc when it leaves this point. The pattern is up to your
            -- interlocking.
            -- on_leave_rc = "B-ALP-T1N K-STN-CLEAR-ROUTE",
        },

        ["BRA:1:S1"] = {
            delay = 10,
            reverse = true,
            next  = "ALP:1:N1",
            dir   = "N",

            depint = "00;00;06;00",
            depoff = "00;00;03;00",  -- offset 3 minutes within the same
                                     -- 6-minute pattern as ALP
        },
    },
}
```

A few important things to notice:

* **The keys in `stations` are `point_id`s** — they are exactly the strings
  formed by `station_id .. ":" .. track_id .. ":" .. point_id` from step 2.
  If a key here does not match a `F.stn_v3` track in the world, the train
  will not stop there (or worse, will be told the track is misconfigured).
* **The `next` field** is itself a `point_id`. By the time a train leaves a
  station, the system uses `next` to register the train's *destination*
  checkpoint; that destination is then walked backwards when estimating
  arrival times.
* **`termini`** is optional. If you provide it, the keys are the same
  direction letters you use in `dir` (`N`, `S`, `E`, `W`, or even
  `CW`/`ACW` for loops), and the values are `station_id`s. The system then
  shows "Heading to: \<name\>" using the matching entry in
  `F.station_names`. If you skip `termini`, that display is omitted.
* **`rc` vs. `line`**: pick one. If your trains use a `T-…`-style line
  in `advtrains`, set `line = "line_name"` and skip `rc`. If you match
  trains by ad-hoc route codes (e.g. `L-AB1`), keep `rc` and skip `line`.
  See `F.track_match_train` in `src/35-station-tracks.lua` for the exact
  rule.
* **`reverse = true`** is the most common setting for terminus. It tells
  the train tocall `R` (a "reverse" command) before departing, so it
  leavesin the opposite direction. Set it to `false` (or omit it) if
  your track is one-way and the train should not physically reverse
  there.
* **`on_leave_rc`** lets you piggy-back the train's rc list with extra
  codes. The convention used in this repo is `J-…` for route codes and
  `B-…` for station exit codes, terminated by `K-STN-CLEAR-ROUTE` if you
  want `F.stn_v3` to strip the temporary codes again on the next arrival.
  Leave it out until you have a working interlocking.
* **`depint` / `depoff`** is the most powerful timing knob. When both are
  set, the door-close is rounded up to the next occurrence of `depint`
  after `depoff` from the moment the doors opened. Use it to make a
  6-minute shuttle with a clean half-shift offset (here: Bravo departs
  3 minutes after Alpha).

For a two-station shuttle, two entries are enough. For a longer line,
add one entry per stopping point in order, and make the **last** entry's
`next` point back at the first (or at a separate return route).

## 5. Rebuilding and reloading STN_v3

`STN_v3/src/*.lua` is bundled into a single script at build time. To pick up
your changes:

```bash
cd /path/to/twi_atlatc_env
make -C STN_v3
```

This regenerates `STN_v3/env_setup.lua`. Then in the Luanti chat:

```text
/env_setup STN_v3
```

Open the env panel, clear the existing code, paste the contents of the new
`env_setup.lua`, and click *Save* and *Run Init Code*. Your new line and
stations are now live.

If you also need to refresh the bundled `PIS_v3/env_setup.lua`, run
`make -C PIS_v3` the same way and reload that environment too.

## 6. Sanity-checking the new line

Before sending real trains, walk through this checklist:

1. Drive a train manually into the `ALP:1:N1` LuaATC track. You should see
   the in-cab text change to *"Stopping at: Alpha"* and the door open
   after a short delay. If the text says the track is misconfigured,
   re-check that the point_id in `02-config-line.lua` matches the one
   passed to `F.stn_v3`.
2. After the door-close delay, the train should reverse and depart. The
   external display should switch from "Next: Alpha" to "Next: Bravo" once
   the line logic kicks in.
3. If you have a working PIS_v3 panel and a platform display, the platform
   display should now show the train as *arriving* at Bravo. The
   `estimated_time` is computed by `F.list_train_arrival_times` and depends
   on previously-collected run data — for a brand-new line, the first few
   runs will be blank until enough samples have been averaged in (see
   `AVERGING_FACTOR` in `src/10-record-times.lua`).
4. Once the train arrives at Bravo, it should be held at the platform for
   the door-close delay (or until the next `depint` slot), then reverse and
   head back to Alpha.

If any of these steps do not work, the most common causes are:

* The `station_id` in `F.stn_v3({...})` does not match the key in
  `F.station_names` exactly.
* A `point_id` in `stations` does not correspond to a `F.stn_v3` track in
  the world.
* The `next` field of the last station in a route does not point back to
  a valid station, so the train is dispatched to a non-existent
  destination.

## 7. Growing the line

From this baseline, the natural extensions are:

* **More stations** — append more entries to `stations` in the order
  the train should visit them, and make the last entry's `next` point back
  to the first to form a loop (or build a separate one-way line if the
  route is not symmetric).
* **More frequent service** — shorten `depint`. The schedule will adjust
  automatically, but watch the timing on shared sections of track: two
  trains on the same `depint` will not see each other, so plan your
  interlocking accordingly.
* **Display polish** — set `color` and `background_color` on the line
  definition. PIS_v3 will pick them up automatically for the line label.
* **Interlocking integration** — once the basic flow works, add
  `on_leave_rc` strings to the stations and use `K-STN-CLEAR-ROUTE` on
  the train's rc to make `F.stn_v3` clean up those codes again on arrival.
  See the `J-…`/`B-…` examples in `02-config-line.lua`.

That is the full path from "I have a track" to "I have a working line that
STN_v3 and PIS_v3 both know about".
