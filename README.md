# betaflight-tx-lua-scripts

**Important:**

*Some changes in OpenTX 2.2.1 cause this version to have less RAM available for lua scripts than previous versions. The recommendation is for users wanting to update OpenTX on a Taranis X9D (and keep using the Betaflight TX lua scripts) is to use 2.3.1 or higher.*

## How to download the scripts

Please visit the [releases page](https://github.com/betaflight/betaflight-tx-lua-scripts/releases) to download a zip file containing latest version.

## Firmware Considerations

- Betaflight - As a best practice, it is recommended to use the most recent stable release of Betaflight to obtain the best possible results.
- Crossfire - v2.11 or greater
- FrSky - While most receivers work fine, it's recommended to update the XSR family of receivers to their most recent firmware version to correct any known bugs in SmartPort telemetry.

## Installing

**!! IMPORTANT: DON'T COPY THE CONTENTS OF THIS REPOSITORY ONTO YOUR SDCARD !!**

Unzip the files from the link above and drag the contents to your radio. If you do this correctly, the SCRIPTS directory will merge with your existing directories, placing the scripts in their appropriate paths.  You will know if you did this correctly if the bf.lua file shows up in your /SCRIPTS/TELEMETRY directory.

The src directory is not required for use and is only available for maintenance of the code.  While it may work to use this directory, you may encounter memory issues on your transmitter.

### How to install

Bootloader Method

1. Power off your transmitter and power it back on in boot loader mode.
2. Connect a USB cable and open the SD card drive on your computer.
3. Unzip the file and copy the scripts to the root of the SD card.
4. Unplug the USB cable and power cycle your transmitter.

Manual method (varies, based on the model of your transmitter)

1. Power off your transmitter.
2. Remove the SD card and plug it into a computer
3. Unzip the file and copy the scripts to the root of the SD card.
4. Reinsert your SD card into the transmitter
5. Power up your transmitter.

If you copied the files correctly, you can now go into the OpenTx Tools screen (Since OpenTx 2.3.0) and access the Betaflight Configuration tool, or you can use the telemetry screen setup page and set up the script as telemetry page.

### Adding the script as a telemetry page

Setting up the script as a telemetry page will enable access at the press of a button. (For now, this only applies to the Taranis X9D series).

1. Hit the [MENU] button and select the model for which you would like to enable the script.
2. While on the [MODEL SELECTION] screen, long-press the [PAGE] button to navigate to the [DISPLAY] page.
3. Use the [-] button to move the cursor down to [Screen 1] and hit [ENT].
4. Use the [+] or [-] buttons to select the [Script] option and press [ENT].
5. Press [-] to move the cursor to the script selection field and hit [ENT].
6. Select 'bf' and hit [ENT].
7. Long-press [EXIT] to return to your model screen.

To invoke the script, simply long-press the [PAGE] button from the model screen.

### Setting up VTX Tables

If you are using a VTX that supports the SmartAudio or Tramp protocols then bands and channels etc. are managed using vtx tables since firmware version 4.1.0. The betaflight configurator will allow you to save your configuration to a _craftname_.lua file. Place this into the BF\VTX folder on the root of the SD card and rename it to match the model you use on your transmitter for this craft. The lua scrips will then use this information on the VTX configuration screen instead of the defaults.

## Building from source

- Be sure to have `LUA 5.2` installed in the path
- Run `./bin/build.sh` from the root folder
- Compiled files will be created a the `obj` in the root folder. Copy the files to your transmitter as instructed in the `Installing` section below as if you unzipped from a downloaded file.