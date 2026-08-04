# PIS v3 remote interrupt reference

PIS v3 does not handle train status on its own; instead, it receives train status with respect to tracks.

## Train identifiers

PIS v3 tracks trains on a per-track basis. Each train is identified by a primary `train_number`, the scheduled identifier of the train (the service the timetable assigns to the train). Trains may also carry a secondary `atc_id`, the identifier of the physically running train in the ATC system. The `train_number` is the key under which PIS v3 stores the train on a track; the `atc_id` is stored alongside it for reference.

* `train_number` — primary identifier (string). Used as the storage key per track. Two trains with the same `train_number` on the same track are treated as the same train.
* `atc_id` — secondary identifier (string of digits, or a positive number). Identifies the physical train behind the schedule. Multiple `train_number`s can share the same `atc_id` (e.g. a service is later re-assigned to a different physical train), and a single `train_number` may be carried by different `atc_id`s over time.

At least one of the two must be provided on every message. If `train_number` is omitted but `atc_id` is present, PIS v3 synthesises a `train_number` of `"_ATCID-" .. atc_id`; this is a fallback for callers that only know the physical train and lets them continue to operate against the old API. Callers that know both are encouraged to send both.

## Sending messages to PIS v3

Messages should be sent via external interrupt (`interrupt_pos`) from the data source. The following position accepts messages:

* `"PIS_v3_ext_int"` (real pos: `POS(4179,23,-109)`)

Optional: `source_id` is a string identifying the source of the event for debugging purposes. `return_to` and `return_iid` are data for returning execution status via external interrupt. The return table will be in the format `{ iid = iid, ok = true / false, err = "error message" }`.

Basic format:

```lua
{
    type = "<message type>",

    source_id = "<source identifier>",
    return_to = POS(x, y, z),
    return_iid = "<return identifier>",
    -- <other parameters...>
}
```

## Message references

### `type = "update_train"`

`type = "update_train"` is used to update the status of a train on a track. This message can be sent regardless of whether an entry already exists for that train on that track; later entries would override earlier entries. Developers should not assume an entry exists (data are cleared on every server restarts or environment reprograms), and should resend the entry at any time it can acquire the train's status.

Basic format:

```lua
{
    type = "update_train",

    source_id = "<source identifier>",
    return_to = POS(x, y, z),
    return_iid = "<return identifier>",

    train_number = "<train number>", -- Optional if atc_id is given
    atc_id = train_atc_id,           -- Optional if train_number is given
    train_status = "<status>"

    station_id = "<station id>",
    track_id = "<track id>",

    -- <other parameters...>
}
```

#### `train_status = "arriving"`, `train_status = "approaching"`

`"arriving"` is used when the train is estimated or scheduled to arrive at that time, but it is still too far away to actively notify passengers; `"approaching"` is used when the train is close to the station so that passengers should be actively notified. The `"approaching"` stage is optional yet recommended.

As a real-life reference, `"arriving"` is used in most cases, while `"approaching"` is used when you hear "the train to &lt;somewhere&gt; is arriving, please stand behind the yellow line." It is usually good enough to trigger this event when `event.approach` is fired on your station track.

The `line_code` parameter is the short code of the line the train is running. The maximum number of characters of this field is 4. It is often the same as, though need not to be, the internal line ID of the line.

The `line_name` parameter is the full name of the line the train is running. It is a [variable-length string object](#variable-length-string-object).

The `line_color` and `line_background_color` parameters are the colors or the lines in hex numbers. Often used by the Digiscreen displays.

The `heading_to` parameter is a [variable-length string object](#variable-length-string-object) of the terminus's name. For loop lines, texts like "Clockwise loop" may be used instead.

The `no_to_prefix` paramater is used to supress `"To "` from appearing in front of `heading_to` in displays.

The `direction_code` paramater is a short code of the train's direction, such as "W" for westbound and "ACW" for anticlockwise. Used on compat displays to show the train's direction.

The `estimated_time` parameter should be a railway time object of the time the train is estimated to arrive and stop on the track. This parameter is required.

```lua
{
    type = "update_train",

    source_id = "<source identifier>",
    return_to = POS(x, y, z),
    return_iid = "<return identifier>",

    train_number = "<train number>", -- Optional if atc_id is given
    atc_id = train_atc_id,           -- Optional if train_number is given
    train_status = "arriving" / "approaching",

    station_id = "<station id>",
    track_id = "<track id>",

    line_code = "<line code>",
    line_name = "<line name>",
    line_color = 0x000000,
    line_background_color = 0xFFFFFF,
    heading_to = "<station name>" / { "<longer name>", "<shorter name>" },
    no_to_prefix = false,
    direction_code = "<direction code>",

    estimated_time = rwt.now(), -- Example
}
```

#### `train_status = "stopped"`

`"stopped"` is used when the train had stopped on the track.

The `line_code` parameter is the short code of the line the train is running. The maximum number of characters of this field is 4. It is often the same as, though need not to be, the internal line ID of the line.

The `line_name` parameter is the full name of the line the train is running. It is a [variable-length string object](#variable-length-string-object).

The `heading_to` parameter is a [variable-length string object](#variable-length-string-object) of the terminus's name. For loop lines, texts like "Clockwise loop" may be used instead.

The `no_to_prefix` paramater is used to supress `"To "` from appearing in front of `heading_to` in displays.

The `direction_code` paramater is a short code of the train's direction, such as "W" for westbound and "ACW" for anticlockwise. Used on compat displays to show the train's direction.

The `estimated_time` parameter should be a railway time object of the time the train is estimated to shut its doors. This is optional but recommended. If absent, the PIS will not hint when the train will leave.

```lua
{
    type = "update_train",

    source_id = "<source identifier>",
    return_to = POS(x, y, z),
    return_iid = "<return identifier>",

    train_number = "<train number>", -- Optional if atc_id is given
    atc_id = train_atc_id,           -- Optional if train_number is given
    train_status = "stopped",

    station_id = "<station id>",
    track_id = "<track id>",

    line_code = "<line code>",
    line_name = "<line name>",
    heading_to = "<station name>" / { "<longer name>", "<shorter name>" },
    no_to_prefix = false,
    direction_code = "<direction code>",

    estimated_time = rwt.now(), -- Example, optional
}
```

#### `train_status = "deregister"`

`"deregister"` is used when the train should be deregistered from the status board of that track. This differs from `type = "deregister_train"`, which removed the train from every status boards PIS v3 handles.

```lua
{
    type = "update_train",

    source_id = "<source identifier>",
    return_to = POS(x, y, z),
    return_iid = "<return identifier>",

    train_number = "<train number>", -- Optional if atc_id is given
    atc_id = train_atc_id,           -- Optional if train_number is given
    train_status = "deregister",

    station_id = "<station id>",
    track_id = "<track id>",
}
```

### `type = "deregister_train"`

`type = "deregister_train"` is used when a train should vanish from the PIS entirely. This should be used when it is 100% sure the train is out of service, for example, when entering a depot.

Exactly one of `train_number` or `atc_id` must be provided:

* `train_number` — every PIS entry keyed by this `train_number` (across all tracks) is removed.
* `atc_id` — every PIS entry whose stored `atc_id` matches is removed. This is the slower path; it scans every track and every train on it.

Sending both `train_number` and `atc_id` together is rejected.

```lua
{
    type = "deregister_train",

    source_id = "<source identifier>",
    return_to = POS(x, y, z),
    return_iid = "<return identifier>",

    train_number = "<train number>", -- OR
    atc_id = train_atc_id,           -- OR (exactly one of the two)
}
```

## Object reference

### Variable-length string object

A variable-length string object is either a string or a table of strings in descending order of length. For example:

```lua
-- The table format
{
    "Alcantaramark's Factory",
    "Alcantaramark's",
}

-- The string format
"Alcantaramark's Factory"
```

When PIS v3 interacts with a variable-length string object, it will try the longest possible name. If the maximum number of characters accepted is lower than the number of characters of the last alternative, the last alternative will be cut.
