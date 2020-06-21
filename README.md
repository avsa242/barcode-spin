# barcode-spin
--------------

This is a P8X32A/Propeller, ~~P2X8C4M64P/Propeller 2~~ library for generating barcodes

**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) ~~or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P)~~. Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.

## Salient Features

* Generates barcodes from ASCII messages (CODE39, CODE128)

## Requirements

P1/SPIN1:
* spin-standard-library
* Initial demo app requires an IL3820-based E-Paper display

~~P2/SPIN2:~~
* ~~p2-spin-standard-library~~

## Compiler Compatibility

* P1/SPIN1: OpenSpin (tested with 1.00.81)
* ~~P2/SPIN2: FastSpin (tested with 4.1.10-beta)~~ _(not implemented yet)_
* ~~BST~~ (incompatible - no preprocessor)
* ~~Propeller Tool~~ (incompatible - no preprocessor)
* ~~PNut~~ (incompatible - no preprocessor)

## Limitations

* Very early in development - may malfunction, or outright fail to build
* There's no validation performed in the generation of barcodes (valid input chars, etc)
* Working buffer for generating barcodes is a fixed size built into each barcode library

## TODO

- [x] Implement CODE39
- [ ] Implement CODE39 checksum
- [ ] Implement CODE39 Extended
- [ ] Implement DataMatrix
- [ ] Implement QR Codes
- [ ] Make more user-friendly
