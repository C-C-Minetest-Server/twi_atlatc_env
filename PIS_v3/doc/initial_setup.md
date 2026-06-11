# PIS_v3 Initial setup

This document covers the initial setups of the Passenger Information System, version 3.

## Prerequisite

Install [Advanced Trains](https://content.luanti.org/packages/orwell/advtrains/) in your world. Enable at least `advtrains`, `advtrains_interlocking`, `advtrains_luaautomation`, `advtrains_train_track`, and `serialize_lib`. Also, install [1F616EMO's fork of Digiscreen](https://github.com/C-C-Minetest-Server/digiscreen).

Grant yourself the `atlatc` and `track_builder` privileges.

Install [GNU Make](https://www.gnu.org/software/make/) (`make`) on your computer:

* On Debian/Ubuntu: `sudo apt install make`
* On Fedora: `sudo dnf install make`
* On macOS: `xcode-select --install`
* On Windows: Download [Make for Windows](https://gnuwin32.sourceforge.net/packages/make.htm)
* On Android: Install [Termux](https://termux.dev/), then follow the instructions for Debian Linux

## Bundling the LuaATC environment initialization code

Clone the repository, then use `make` to bundle the script:

```bash
git clone https://github.com/C-C-Minetest-Server/twi_atlatc_env
cd twi_atlatc_env
make -C PIS_v3
```

The resulting bundled script is located at `PIS_v3/env_setup.lua`.

## Setting up LuaATC environment

Run the following in the chatroom:

```text
/env_create PIS_v3
/env_setup PIS_v3
```

Paste the [bundled script](#bundling-the-luaatc-environment-initialization-code) into the main text box, then click "Save" and "Run Init Code".

## Setting up control panels

**External Event Receiver**: Place down a LuaATC Operation Panel (`advtrains_luaautomation:oppanel`) somewhere on the map. It is recommended to hide it from plain sight. Right-click the panel with a Passive Component Naming Tool (`advtrains_luaautomation:pcnaming`), and name it `PIS_v3_ext_int`.

**Plain Text Advertisement Updater**: Place down a LuaATC Operation Panel with the following code, and then *punch it*:

```lua
if event.punch then
    interrupt_safe(1)
elseif event.int then
    F.update_advertisement()
    interrupt_safe(1)
end
```

**Digital Display Marquee Updater**: Place down a LuaATC Operation Panel with the following code, and then *punch it*:

```lua
if event.punch then
    interrupt_safe(0.2)
elseif event.int then
    F.update_marquee()
    interrupt_safe(0.2)
end
```

## Done

You're all set! Check `pis_display.md` for how to set up platform displays.

You will need another set of code that collects information for PIS_v3. STN_v3 is a good starting point, and is also provided in this repository.
