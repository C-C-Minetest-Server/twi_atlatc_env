# Adding an intermediate station with directional platform tracks

This document extends the **Alpha–Bravo** shuttle from
[`first_line.md`](first_line.md) into a three-station line
**Alpha → Bravo → Charlie → Bravo → Alpha**, used to demonstrate an
intermediate station. In the process we will also rework the line so that
each direction uses its own dedicated platform track at the intermediate
station — the realistic case for a busy station.

You should be comfortable with the basics before reading this. If you have
not done so yet, work through `first_line.md` end-to-end and verify the
two-station shuttle works. We will not repeat the prerequisites in detail.

What we are building:

* Stations **Alpha** (`ALP`), **Bravo** (`BRA`), **Charlie** (`CHA`).
* Line `ABC`, code `ABC`, that runs **Alpha → Bravo → Charlie → Bravo → Alpha**
  in a continuous loop.
* At **Bravo** only, two separate platform tracks — one for the
  Alpha-bound leg, one for the Charlie-bound leg — so northbound and
  southbound trains do not collide on the same platform.
* At **Alpha** and **Charlie**, the line terminates; a single track per
  station is enough, and the train reverses there.

The line still runs on a 6-minute headway; we will space the three stations
two minutes apart within that pattern so the dwell at Bravo and Charlie is
visible in the PIS.

## 1. The new track layout

The physical layout is the same as the two-station shuttle, but with:

* A new station **Charlie** between Alpha and Bravo — but on the *opposite*
  side of Bravo from Alpha. The train runs Alpha → Bravo → Charlie → Bravo
  → Alpha, so Bravo is the **intermediate** stop, and Charlie is the
  terminus.
* At **Bravo**, **two platform tracks**:
  * `BRA:1:N1` — northbound, used by trains heading from Charlie *to* Alpha
    (i.e. the leg *Charlie → Bravo → Alpha*).
  * `BRA:1:S2` — southbound, used by trains heading from Alpha *to* Charlie
    (i.e. the leg *Alpha → Bravo → Charlie*).

  Note the `track_id` deliberately differs between the two (`1` for
  northbound, `2` for southbound) — it is a *physical* identifier of the
  platform, so two platforms at the same station are `1` and `2`, not both
  `1`. The `point_id` (`N1` vs. `S2`) is a *directional* identifier within
  that platform.
* At **Alpha** and **Charlie**, a single track per station, which serves
  both directions (the train simply reverses there). We will use
  `point_id = "S1"` at Alpha (the southbound arrival / northbound
  departure) and `point_id = "N1"` at Charlie (the northbound arrival /
  southbound departure).

The reason for the directional split at Bravo is that a single bidirectional
platform can only hold one train at a time. With a 6-minute headway in
both directions, a northbound train and a southbound train can meet at
Bravo every 3 minutes. Splitting them onto two physical platforms means
neither train ever has to wait for the other to clear.

If you are building a smaller station where this is not a concern, you can
collapse both directions back onto a single track and use `point_id = "N1"`
and `point_id = "S1"` for the two directions. The line configuration in
section 3 is the only thing that changes; the layout discussion above is
still useful for understanding the conventions.

## 2. Updating the F.stn_v3 track programs

Lay the new LuaATC tracks first, then program each one with a `F.stn_v3`
call (see `first_line.md` §2 for the full parameter list). The minimum
programs are:

* **Alpha, track 1, southern platform** (only one track, used in both
  directions — the train reverses here):

  ```lua
  F.stn_v3({
      station_id = "ALP",
      track_id = "1",
      point_id = "S1",
  })
  ```

* **Bravo, track 1, northern end** (northbound — for the
  *Charlie → Bravo → Alpha* leg):

  ```lua
  F.stn_v3({
      station_id = "BRA",
      track_id = "1",
      point_id = "N1",
  })
  ```

* **Bravo, track 2, southern end** (southbound — for the
  *Alpha → Bravo → Charlie* leg):

  ```lua
  F.stn_v3({
      station_id = "BRA",
      track_id = "2",
      point_id = "S2",
  })
  ```

* **Charlie, track 1, northern platform** (only one track, used in both
  directions — the train reverses here):

  ```lua
  F.stn_v3({
      station_id = "CHA",
      track_id = "1",
      point_id = "N1",
  })
  ```

Four tracks total, four small LuaATC programs. Compare this to the original
two-station setup: we added two tracks (one for Charlie, one for the new
direction at Bravo) but the per-track code is identical in shape.

## 3. Adding the new station to 01-config-station.lua

Open `STN_v3/src/01-config-station.lua` and add a third entry to
`F.station_names`. The existing `ALP` and `BRA` entries from
`first_line.md` §3 stay as they are; just append:

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
    CHA = {
        "Charlie's Crossing",
        "Charlie X-ing",
        "Charlie",
    },
}
```

`F.station_interchange` is still not needed: there is only one line, and
no two lines meet at Bravo. (If you later build a second line through
Bravo, that is when you come back to add an entry there — see the
"Interchanges" section in the file for examples.)

## 4. Reworking the line in 02-config-line.lua

We are going to **replace** the `AB1` line from `first_line.md` with an
`ABC` line. The two share the same overall shape, but `ABC` walks through
**five** stopping points instead of two — one for each leg of the route,
including the *second* pass through Bravo. The order is the physical order
the train visits them:

```
ALP:1:S1  →  BRA:2:S2  →  CHA:1:N1  →  BRA:1:N1  →  ALP:1:S1
```

That is: leave Alpha, head south to Bravo (track 2, southbound), continue
south to Charlie, reverse at Charlie and come back north to Bravo (track 1,
northbound), then continue north back to Alpha. Close the loop by setting
the last entry's `next` back to `ALP:1:S1`.

```lua
F.stn_v3_lines["ABC"] = {
    -- 1. Train matching
    rc = "L-ABC",

    -- 2. PIS display parameters
    code = "ABC",
    name = {
        "Alpha–Bravo–Charlie Loop",
        "ABC Loop",
        "ABC",
    },
    termini = {
        N = "ALP",
        S = "CHA",
    },

    -- 3. The route itself
    stations = {
        -- Leg 1: Alpha → Bravo (southbound)
        ["ALP:1:S1"] = {
            delay = 10,
            reverse = true,
            next  = "BRA:2:S2",
            dir   = "S",

            -- Alpha is the northern terminus. The full 6-minute pattern
            -- starts here at offset 0; the train is scheduled to leave at
            -- the top of every 6-minute slot.
            depint = "00;00;06;00",
            depoff = "00;00;00;00",
        },

        -- Leg 1 cont.: arrival at Bravo (southbound platform)
        ["BRA:2:S2"] = {
            delay = 10,
            -- No reverse at this platform — the train continues south
            -- past Bravo toward Charlie.
            reverse = false,
            next  = "CHA:1:N1",
            dir   = "S",

            -- Two minutes into the 6-minute pattern.
            depint = "00;00;06;00",
            depoff = "00;00;02;00",
        },

        -- Leg 2: Bravo → Charlie (southbound), terminating
        ["CHA:1:N1"] = {
            delay = 10,
            reverse = true,
            next  = "BRA:1:N1",
            dir   = "N",

            -- Four minutes into the 6-minute pattern.
            depint = "00;00;06;00",
            depoff = "00;00;04;00",
        },

        -- Leg 3: Charlie → Bravo (northbound)
        ["BRA:1:N1"] = {
            delay = 10,
            reverse = false,
            next  = "ALP:1:S1",
            dir   = "N",

            -- Wait — see the note below about depoff here. The "natural"
            -- offset for a 2-minute travel from Charlie would be 6 minutes
            -- after CHA:1:N1's offset, but the pattern is 6 minutes, so
            -- we wrap: 04;00 + 02;00 = 06;00 ≡ 00;00 modulo 06;00.
            depint = "00;00;06;00",
            depoff = "00;00;00;00",
        },
    },
}
```

A few things worth pointing out in this configuration:

* **Five legs, four `stations` entries.** The train visits **five**
  stopping points (the four listed, plus the *return* to Alpha that closes
  the loop), but we only need four entries because the last `next`
  points back to the first.
* **Two entries for the same station.** `BRA:2:S2` and `BRA:1:N1` are
  different `point_id`s — different `station_id:track_id:point_id`
  strings — so STN_v3 treats them as two independent stopping points. This
  is exactly the use case for the `point_id` field: a station can have
  many stopping points, one per LuaATC track. The "lines on stopping
  point" mapping in `src/35-station-tracks.lua` is built off the full
  point_id, not just the `station_id`, so the two Bravo entries do not
  collide.
* **`reverse = false` at the Bravo platforms.** The train is not turning
  around at Bravo in either direction; it is passing through on its way
  to the next station. We make that explicit so the operator reading the
  config does not have to guess.
* **The `depint` / `depoff` numbers wrap.** The door-close scheduler
  rounds the door-close time up to the next occurrence of `depint` after
  `depoff`. With a 6-minute pattern, a train that arrives at `BRA:1:N1`
  2 minutes after leaving Charlie will close its doors 6 minutes later
  (i.e. at the start of the next cycle), which is exactly the same instant
  Alpha is due to dispatch its next train. That is fine: by the time the
  train leaves Bravo it is in a different physical section of track from
  Alpha. If you want a cleaner separation, shorten `depint` to
  `"00;00;03;00"` and add 3 minutes to each `depoff` — the loop will
  simply run at 3-minute rather than 6-minute frequency.
* **`termini` is set.** With a loop line, "terminus" is a slightly fuzzy
  concept; we have chosen the two ends of the line (Alpha at the north
  end, Charlie at the south end) for the `dir = N` and `dir = S`
  displays. Trains heading north show "Heading to: Alpha"; trains heading
  south show "Heading to: Charlie". The leg *Bravo → Charlie* and
  *Charlie → Bravo* are both `dir = S` and `dir = N` respectively, so the
  display flips correctly as the train passes through Bravo.

## 5. What changed versus the two-station shuttle

A short summary of the deltas, in case you are upgrading an existing
shuttle in place:

* **New LuaATC track** at Charlie: `CHA:1:N1`. Add the `F.stn_v3` call as
  shown in §2.
* **New LuaATC track** at Bravo for the southbound direction:
  `BRA:2:S2`. The original `BRA:1:S1` from the two-station setup is no
  longer used by the new line — physically you can remove it, or leave it
  in place as a maintenance/backup track (and just not list it in the new
  line's `stations`).
* **New station entry** in `01-config-station.lua`: `CHA`.
* **New line entry** in `02-config-line.lua` (`ABC`), replacing `AB1`.
  The two cannot coexist with the same `rc =` because they would compete
  for trains on the shared `ALP:1` track.

## 6. Sanity-checking the new line

The same checklist from `first_line.md` §6 applies, but a few extra
questions for this layout:

1. Drive a train manually from Alpha to Bravo. It should stop at
   `BRA:2:S2` (southbound platform) and show "Next: Charlie" on the
   external display, **not** "Next: Alpha". If it shows "Next: Alpha"
   instead, the `next` field of the `ALP:1:S1` entry is wrong.
2. Continue to Charlie. The train should stop at `CHA:1:N1`, hold for the
   door-close delay, reverse, and head back north.
3. On the return leg, the train should stop at `BRA:1:N1` (the *northbound*
   platform, track 1) — not at `BRA:2:S2` again. If it stops at
   `BRA:2:S2` it is a sign the two Bravo `point_id`s have been swapped in
   the config.
4. From Bravo, the train should continue north to `ALP:1:S1`, then
   reverse and head south to begin the loop again.

If the train ever stops at a `F.stn_v3` track and the in-cab text reads
*"Station track misconfigured. Contact railway operator."*, the most
common cause is that a `point_id` in `F.stn_v3({...})` does not match the
key in `F.stn_v3_lines["ABC"].stations`. With four tracks in play, this is
the easiest mistake to make — work through the four `point_id`s on a
piece of paper before reloading.

## 7. Growing further

With the intermediate-station pattern in place, the natural next steps
are:

* **Two platforms at Alpha and Charlie too** — once service gets busier,
  the same problem appears at the termini: a northbound arrival and a
  southbound arrival at Alpha would otherwise share a single platform.
  The fix is identical: split `ALP:1` into `ALP:1` (northbound) and
  `ALP:2` (southbound), and update the two `ALP:1:S1` references in the
  line config accordingly.
* **A second line meeting at Bravo** — the moment a second line passes
  through Bravo, register an entry in `F.station_interchange` for `BRA`
  and list the two lines (and the optional `interchange_line_alias` key
  if the same physical line has a different identifier depending on
  direction). The PIS will then offer "Change here for …" hints.
* **Section-based `depint`** — once the line is busier than 3-4 trains,
  the simple "depart at the next multiple" scheduler starts losing
  granularity. At that point switch to a section-based timetable by
  splitting the pattern at Bravo (different `depint` on either side).
  The format string `cc;hh;mm;ss` in the `depint` field is happy to
  carry centisecond precision for that case.
