# betaflight-tx-lua-scripts

### How to download the scripts

[Click here](http://null.eastus.cloudapp.azure.com/job/Betaflight%20Lua%20-%20X7,%20X9,%20X9D,%20X9D+/lastSuccessfulBuild/artifact/obj/SCRIPTS/*zip*/SCRIPTS.zip) to download a zip file containing latest version.

## Firmware Considerations
- Betaflight - As a best practice, it is recommended to use the most recent stable release of Betaflight to obtain the best possible results.
- Crossfire - v2.11 or greater
- FrSky - While most receivers work fine, it's recommended to update the XSR family of receivers to their most recent firmware version to correct any known bugs in SmartPort telemetry.

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

## Invoking from the OpenTX Crossfire configuration script
This package contains a slight modification to the standard OpenTx crossfire.lua script that will load the configuration pages while configuring your Crossfire devices.
1. From your model screen, long-press [MENU] to reveal the [RADIO SETUP] screen.
2. Press the [PAGE] button to open the [SD CARD] browser.
3. Navigate to the [CROSSFIRE] directory using [-] or [+] and press [ENT].
4. Navigate to the 'crossfire.lua' file, long-press [ENT], and select [Execute] by pressing [ENT].

If your flight controller is running the proper firmware, you will see 'Betaflight X.X.X: ABCD' in the list of Crossfire devices, where X.X.X is the Betaflight version (3.2.0 or greater) and ABCD is the board identifier (ie. BFF3 for Betaflight F3).

Select this device by pressing [-] or [+], press [ENT] and the configuration pages will load.  To exit back to the device list, hit the [EXIT] button at any time.
