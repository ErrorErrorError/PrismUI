<!-- Banner Image -->
<img src="images/PrismUI-Logo.png" width="100" height="100">


# PrismUI

<!-- Banner Image -->
![PrismUI Banner](images/PrismUI-Banner-Text.png)

<!-- Badges -->
![Build Status](https://action-badges.now.sh/ErrorErrorError/PrismUI)
[![GitHub forks](https://img.shields.io/github/forks/ErrorErrorError/PrismUI)](https://github.com/ErrorErrorError/PrismUI/network)
[![GitHub issues](https://img.shields.io/github/issues/ErrorErrorError/PrismUI)](https://github.com/ErrorErrorError/PrismUI/issues)
[![GitHub stars](https://img.shields.io/github/stars/ErrorErrorError/PrismUI)](https://github.com/ErrorErrorError/PrismUI/stargazers)
[![GitHub license](https://img.shields.io/github/license/ErrorErrorError/PrismUI)](https://github.com/ErrorErrorError/PrismUI/blob/master/LICENSE) 
[![Join the chat at https://gitter.im/ErrorErrorError/PrismUI](https://badges.gitter.im/ErrorErrorError/PrismUI.svg)](https://gitter.im/ErrorErrorError/PrismUI?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

> Control MSI Laptops x Steelseries RGB peripherals on macOS!

This is a revised version of my previous repo SSKeyboardHue. The driver and the app is now all within one app and uses pure Swift!

## Download

### Latest Stable Version

[![Download from https://github.com/ErrorErrorError/PrismUI/releases/latest](https://img.shields.io/github/v/release/ErrorErrorError/PrismUI?color=%2300AABB&label=Download)](https://github.com/ErrorErrorError/PrismUI/releases/latest)

### Latest Alpha Version

[![Download from https://github.com/ErrorErrorError/PrismUI/releases/](https://img.shields.io/github/v/release/ErrorErrorError/PrismUI?include_prereleases&label=Download)](https://github.com/ErrorErrorError/PrismUI/releases/)

## Usage

Download the stable version and install the app to `~/Applications` folder.

Open PrismUI app and customize your RGB peripherals!

## Compatibility

As of creating this README, only models with Per-Key RGB keyboard work. Soon I will see if I can bring support for three-region keyboards, and with the help of the community support Mystic Light peripherals.

As for Per-Key RGB keyboards, all animations work as intended. If there are any issues please create an issue request.

I am happy to support more MSI or SteelSeries peripherals on macOS!

### Tested On:
- MSI GS65

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)

## Credits
- [Stevelacy](https://github.com/stevelacy/msi-keyboard-gui) for the inspiration of creating a gui.
- [Askannz](https://github.com/Askannz/msi-perkeyrgb) for `.perKey` keycodes.
- [TauAkiou](https://github.com/TauAkiou/msi-perkeyrgb) for their documentation with the effects implementation.
- [flozz](https://github.com/flozz/rivalcfg) for their color delta calculations.