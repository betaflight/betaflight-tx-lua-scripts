# betaflight-tx-lua-scripts

### Important:

Some changes in the recently released OpenTX 2.2.1 cause this version to have less RAM available for lua scripts than previous versions. This often leads to problems when using the Betaflight TX lua scripts on the Taranis X9D. A discussion of these problems can be found [here](https://github.com/betaflight/betaflight-tx-lua-scripts/issues/97).
A potential fix to increase the amount of RAM available has been identified: (https://github.com/opentx/opentx/pull/5579).
For now, the recommendation is for users wanting to update OpenTX from 2.2.0 to 2.2.1 on a Taranis X9D (and keep using the Betaflight TX lua scripts) to hold on and monitor the situation, in the hope that OpenTX will release a version with this bugfix in the near future.

### How to download the scripts

Please visit the [releases page](https://github.com/betaflight/betaflight-tx-lua-scripts/releases) to download a zip file containing latest version.

## Firmware Considerations
- Betaflight - As a best practice, it is recommended to use the most recent stable release of Betaflight to obtain the best possible results.
- Crossfire - v2.11 or greater
- FrSky - While most receivers work fine, it's recommended to update the XSR family of receivers to their most recent firmware version to correct any known bugs in SmartPort telemetry.

## Building from source
- Be sure to have `LUA 5.2` installed in the path
- Run `./bin/build.sh` from the root folder
- Compiled files will be created a the `obj` in the root folder. Copy the files to your transmitter as instructed in the `Installing` section below as if you unzipped from a downloaded file.

## Installing

!! IMPORTANT: DON'T COPY THE CONTENTS OF THIS REPOSITORY ONTO YOUR SDCARD !!

Unzip the files from the link above and drag the contents to your radio. If you do this correctly, the SCRIPTS directory will merge with your existing directories, placing the scripts in their appropriate paths.  You will know if you did this correctly if the bf.lua file shows up in your /SCRIPTS/TELEMETRY directory.

The src directory is not required for use and is only available for maintenance of the code.  While it may work to use this directory, you may encounter memory issues on your transmitter.

How to install:

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

If you copied the files correctly, you can now go into the telemetry screen setup page and set up the script as telemetry page.

## Adding the script as a telemetry page
Setting up the script as a telemetry page will enable access at the press of a button. (For now, this only applies to the Taranis X9D series).
1. Hit the [MENU] button and select the model for which you would like to enable the script.
2. While on the [MODEL SELECTION] screen, long-press the [PAGE] button to navigate to the [DISPLAY] page.
3. Use the [-] button to move the cursor down to [Screen 1] and hit [ENT].
4. Use the [+] or [-] buttons to select the [Script] option and press [ENT].
5. Press [-] to move the cursor to the script selection field and hit [ENT].
6. Select 'bf' and hit [ENT].
7. Long-press [EXIT] to return to your model screen.

To invoke the script, simply long-press the [PAGE] button from the model screen.
