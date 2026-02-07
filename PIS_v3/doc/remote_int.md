# PIS v3 remote interrupt reference

PIS v3 does not handle train status on its own; instead, it receives train status with respect to tracks.

## Sending messages to PIS v3

Messages should be sent via external interrupt (`interrupt_pos`) from the data source. The following position accepts messages:

* _TBD_

Basic format:

```lua
{
    type = "<message type>",
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
    atc_id = train_atc_id,
    train_status = "<status>"

    station_id = "<station id>",
    track_id = "<track id>",

    -- <other parameters...>
}
```

#### `train_status = "arriving"`, `train_status = "approaching"`

`"arriving"` is used when the train is estimated or scheduled to arrive at that time, but it is still too far away to actively notify passengers; `"approaching"` is used when the train is close to the station so that passengers should be actively notified. The `"approaching"` stage is optional yet recommended.

As a real-life reference, `"arriving"` is used in most cases, while `"approaching"` is used when you hear "the train to &lt;somewhere&gt; is arriving, please stand behind the yellow line."

The `line_code` parameter is the short code of the line the train is running. The maximum number of characters of this field is 4. It is often the same as, though need not to be, the internal line ID of the line.

The `line_name` parameter is the full name of the line the train is running. It is a [variable-length string object](#variable-length-string-object).

The `heading_to` parameter is a [variable-length string object](#variable-length-string-object) of the terminus's name. For loop lines, texts like "Clockwise loop" may be used instead.

The `arriving_at` parameter should be a railway time object of the time the train is estimated to arrive and stop on the track. This parameter is required.

```lua
{
    type = "update_train",
    atc_id = train_atc_id,
    train_status = "arriving" / "approaching",

    station_id = "<station id>",
    track_id = "<track id>",

    line_code = "<line code>",
    line_name = "<line name>",
    heading_to = "<station name>" / { "<longer name>", "<shorter name>" },

    arriving_at = rwt.now(), -- Example
}
```

#### `train_status = "stopped"`

`"stopped"` is used when the train had stopped on the track.

The `line_code` parameter is the short code of the line the train is running. The maximum number of characters of this field is 4. It is often the same as, though need not to be, the internal line ID of the line.

The `line_name` parameter is the full name of the line the train is running. It is a [variable-length string object](#variable-length-string-object).

The `heading_to` parameter is a [variable-length string object](#variable-length-string-object) of the terminus's name. For loop lines, texts like "Clockwise loop" may be used instead.

The `leaving_at` parameter should be a railway time object of the time the train is estimated to shut its doors. This is optional but recommended. If absent, the PIS will not hint when the train will leave.

```lua
{
    type = "update_train",
    atc_id = train_atc_id,
    train_status = "stopped",

    station_id = "<station id>",
    track_id = "<track id>",

    line_code = "<line code>",
    line_name = "<line name>",
    heading_to = "<station name>" / { "<longer name>", "<shorter name>" },

    leaving_at = rwt.now(), -- Example, optional
}
```

#### `train_status = "deregister"`

`"deregister"` is used when the train should be deregistered from the status board of that track. This differs from `type = "deregister_train"`, which removed the train from every status boards PIS v3 handles.

```lua
{
    type = "update_train",
    atc_id = train_atc_id,
    train_status = "deregister",

    station_id = "<station id>",
    track_id = "<track id>",
}
```

### `type = "deregister_train"`

`type = "deregister_train"` is used when a train should vanish from the PIS entirely. This should be used when it is 100% sure the train is out of service, for example, when entering a depot.

```lua
{
    type = "deregister_train",
    atc_id = train_atc_id,
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
