global record Vector
    x: number
    y: number
    z: number
end

global type pcpos = Vector | string

-- Events

global interface Event
    type: string
    
    -- event.<type> = true is intentionally dropped
end

global interface MessageEvent is Event
    get_message: function(self): any
end

global interface HasTrainEvent is Event
    id: string
end

global enum LuaControllerPinName
    "A"
    "B"
    "C"
    "D"
end

global record LuaControllerPin
    x: number
    y: number
    z: number
    name: LuaControllerPinName
end

global interface LuaControllerEvent is Event
    pin: LuaControllerPin
end


global record InitEvent is Event
    where self.type == "init"
end

global record GlobalstepEvent is Event
    where self.type == "globalstep"
end

global record DigilineEvent is Event, MessageEvent
    where self.type == "digiline"
    channel: string
    msg: any

    get_message: function(self): any = macroexp(self: DigilineEvent): number
        return self.msg
    end
end

global record IntEvent is Event, MessageEvent
    where self.type == "int"
    msg: any

    get_message: function(self): any = macroexp(self: IntEvent): number
        return self.msg
    end
end

global type InterruptEvent = IntEvent

global record ExtIntEvent is Event, MessageEvent
    where self.type == "ext_int"
    message: any

    get_message: function(self): any = macroexp(self: ExtIntEvent): number
        return self.message
    end
end

global record ScheduleEvent is Event, MessageEvent
    where self.type == "schedule"
    msg: any

    get_message: function(self): any = macroexp(self: ScheduleEvent): number
        return self.msg
    end
end

global record ApproachEvent is Event, HasTrainEvent
    where self.type == "approach"

    has_entered: boolean
end

global record TrainEvent is Event, HasTrainEvent
    where self.type == "train"
end

global record DisplayEvent is Event
    where self.type == "display"
end

global record RefreshEvent is Event
    where self.type == "refresh"
end

global event: Event

global atc_id: string | nil
global atc_arrow: boolean | nil

-- Basic LuaATC functions

global POS: function(number, number, number): Vector

global getstate: function(parpos: pcpos): string | nil
global setstate: function(parpos: pcpos, newstate: string): (boolean, string | nil)
global is_passive: function(parpos: pcpos): boolean

global interrupt_pos: function(parpos: pcpos, imesg: any)
global train_parts: function(train_id: string): {string} | nil
global get_wagon_train_id: function(wagon_id: string): string | nil
global atc_send_to_train: function(train_id: string, command: string)
global get_slowdown: function(): number

-- advtrains_interlocking addons

global record SignalAspect
    main: number
    dst: number
    proceed_as_main: boolean
    shunt: boolean
end

global enum MainAspectOptions
    "_default"
    "_halt"
end

global type MainAspect = MainAspectOptions | number

global can_set_route: function(signal: pcpos, route_name: string): boolean
global set_route: function(signal: pcpos, route_name: string)
global cancel_route: function(signal: pcpos)
global get_active_route: function(signal: pcpos): string | nil

global get_aspect: function(signal: pcpos): SignalAspect | nil
global set_aspect: function(signal: pcpos, main_asp: MainAspect, rem_signal?: pcpos)
global section_occupancy: function(ts_id: string | number): {string}

-- advtrains_line_automation addons

global record RailwayTimeInstantTable
    c: integer
    h: integer
    m: integer
    s: integer
end

global record RailwayTimeIntervalTable
    sign: number
    c: number
    h: number
    m: number
    s: number
end

global type RailwayTimeInstant = string | number | RailwayTimeInstantTable
global type RailwayTimeInterval = string | number | RailwayTimeIntervalTable

global record rwt
    now: function(): RailwayTimeInstantTable
    new_t: function(c: number, h: number, m: number, s: number): RailwayTimeInstantTable
    new_i: function(sign: number, c: number, h: number, m: number, s: number): number
    to_table: function(rwtime: RailwayTimeInstant): RailwayTimeInstantTable
    t_sec: function(rwtime: RailwayTimeInstant): number
    i_sec: function(rwint: RailwayTimeInterval): number
    to_sec: function(rwint: RailwayTimeInterval): number -- deprecated
    t_str: function(rwtime: RailwayTimeInstant): string
    i_str: function(rwtime: RailwayTimeInterval): string
    to_string: function(rwtime: RailwayTimeInstant): string -- deprecated

    add: function(t1: RailwayTimeInstant, i: RailwayTimeInterval): RailwayTimeInstantTable
    sub: function(t1: RailwayTimeInstant, i: RailwayTimeInterval): RailwayTimeInstantTable
    diff: function(t1: RailwayTimeInstant, t2: RailwayTimeInstant): RailwayTimeIntervalTable

    is_after: function(t1: RailwayTimeInstant, t2: RailwayTimeInstant): boolean
    is_before: function(t1: RailwayTimeInstant, t2: RailwayTimeInstant): boolean

    next_rpt: function(rwtime: RailwayTimeInstant, rpt_interval: RailwayTimeInterval, rpt_offset: RailwayTimeInterval): RailwayTimeInstantTable
    last_rpt: function(rwtime: RailwayTimeInstant, rpt_interval: RailwayTimeInterval, rpt_offset: RailwayTimeInterval): RailwayTimeInstantTable
    time_from_last_rpt: function(rwtime: RailwayTimeInstant, rpt_interval: RailwayTimeInterval, rpt_offset: RailwayTimeInterval): (number, number, number)
    time_to_next_rpt: function(rwtime: RailwayTimeInstant, rpt_interval: RailwayTimeInterval, rpt_offset: RailwayTimeInterval): (number, number, number)
end

-- advtrains_oop addons

global record LZBCheckPoints
    pos: Vector
    index: number
    speed: number
end

global interface Train
    atc_id: number
    atc_arrow: boolean
    is_valid: function(): boolean
end

global record ValidTrain is Train
    where self.is_valid()

    get_id: function(): string
    get_index: function(): number
    train_length: function(): integer
    train_length_meters: function(): integer
    locomotives_in_train: function(): integer
    train_parts: function(): {string}

    atc_send: function(command: string)
    atc_reset: function()
    split_at_index: function(index: integer, cmd: string): boolean
    split_at_fc: function(cmd: string, length_limit: integer): string
    split_off_locomotive: function(cmd: string, len: integer)

    step_fc: function()
    get_fc: function(): {string}
    get_fc_index: function(): {integer}
    set_fc: function(fc_list: {string}, reset_index: integer)

    set_shunt: function()
    unset_shunt: function()
    set_autocouple: function()
    unset_autocouple: function()

    get_line: function(): string
    set_line: function(line: string)
    get_rc: function(): string
    set_rc: function(rc: string)
    has_rc: function(query: string): boolean

    get_speed: function(): number
    get_max_speed: function(): number

    get_text_outside: function(): string
    set_text_outside: function(text: string)
    get_text_inside: function(): string
    set_text_inside: function(text: string)

    get_lzb_checkpoints: function(): {LZBCheckPoints}

    get_ars_disable: function(): boolean
    set_ars_disable: function(value: boolean)
    ars_check_rule_match: function(ars: string | table | nil): boolean
end

global get_train: function(id: string): ValidTrain | nil
