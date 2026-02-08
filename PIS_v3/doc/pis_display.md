# Passenger Information System display unit reference

## `F.get_pis_single_line(def)`

Displays the full name of the train service at all time. Suitable for places where only one train service runs.

```lua
F.get_pis_single_line({
    -- The station ID.
    -- Alternative name: here
    station_id = "<station id>",

    -- The track ID.
    -- Alternative name: platform_id, track
    track_id = "<track id>",

    -- The line name, when there is no data.
    -- Always overriden by the data of the nearest train if present.
    -- type: variable-length string object
    line_name = "<line name>",

    -- The terminus name, when there is no data.
    -- Always overriden by the data of the nearest train if present.
    -- type: variable-length string object
    heading_to = "<terminus name>",

    -- Custom header instead of "PLATFORM #:"
    custom_header = nil,
})
```

## `F.get_pis_multi_line(def)`

Displays the arrival time of up to three trains. Switches to single-line mode to focus on the current train when a train stops. Suitable for intercity platforms and platforms shared among multiple services.

```lua
F.get_pis_multi_line({
    -- The station ID.
    -- Alternative name: here
    station_id = "<station id>",

    -- The track ID.
    -- Alternative name: platform_id, track
    track_id = "<track id>",

    -- `true` indicates that this PIS screen is not set on the platform
    -- i.e., messages like "train approaching" will not be shown
    -- and the screen would not switch into single-line mode when a train stops
    no_current_train = false,

    -- Custom header instead of "PLATFORM #:"
    custom_header = nil,
})
```

## `F.get_pis_compat(def)`

Displays all information in the top two lines. Suitable for places where full-sized PIS is impossible.

```lua
F.get_pis_compat({
    -- The station ID.
    -- Alternative name: here
    station_id = "<station id>",

    -- The track ID.
    -- Alternative name: platform_id, track
    track_id = "<track id>",

    -- The line id, when there is no data.
    -- Always overriden by the data of the nearest train if present.
    -- Alternative name: line
    line_id = "<line id>",

    -- The direction code, when there is no data.
    -- Always overriden by the data of the nearest train if present.
    direction_code = "<direction code>",
})
```

## `F.get_status_textline_line(def)`

Get a line of station status.

Visual example:

```text
1: GRH2 -> DUI     Arr. 16
2: GRH2 -> KIH     Dep.  3
```

```lua
F.get_status_textline_line({
    -- The station ID.
    -- Alternative name: here
    station_id = "<station id>",

    -- The track ID.
    -- Alternative name: platform_id, track
    track_id = "<track id>",

    -- The line id, when there is no data.
    -- Always overriden by the data of the nearest train if present.
    -- Alternative name: line
    line_id = "<line id>",

    -- The station name of the terminus
    -- Only used when heading_to_id is absent.
    -- other string like Clockwise can be used
    -- type: variable-length string object
    heading_to = "<heading_to>",
})
````
