# barcode-spin
--------------

This is a P8X32A/Propeller, ~~P2X8C4M64P/Propeller 2~~ library for generating barcodes

![CODE39 on E-Paper](https://github.com/avsa242/barcode-spin/blob/testing/code39-prop-epaper.jpg)
![CODE39 on E-Paper (w/Checksum)](https://github.com/avsa242/barcode-spin/blob/testing/code39-cksum-prop-epaper.jpg)
**IMPORTANT**: This software is meant to be used with the [spin-standard-library](https://github.com/avsa242/spin-standard-library) (P8X32A) or [p2-spin-standard-library](https://github.com/avsa242/p2-spin-standard-library) (P2X8C4M64P). Please install the applicable library first before attempting to use this code, otherwise you will be missing several files required to build the project.


## Salient Features

* CODE39, CODE128: Generates barcodes from ASCII messages
* CODE39: decode barcode data to ASCII


## Requirements

P1/SPIN1:
* spin-standard-library

P2/SPIN2:
* p2-spin-standard-library

Both:
* Demo apps require a display driver

## Compiler Compatibility

| Processor | Language | Compiler               | Backend      | Status                |
|-----------|----------|------------------------|--------------|-----------------------|
| P1        | SPIN1    | FlexSpin (6.2.1)       | Bytecode     | OK                    |
| P1        | SPIN1    | FlexSpin (6.2.1)       | Native/PASM  | OK                    |
| P2        | SPIN2    | FlexSpin (6.2.1)       | NuCode       | FTBFS                 |
| P2        | SPIN2    | FlexSpin (6.2.1)       | Native/PASM2 | OK                    |

(other versions or toolchains not listed are __not supported__, and _may or may not_ work)


## Limitations

* Very early in development - may malfunction, or outright fail to build
* There's no validation performed in the generation of barcodes (valid input chars, etc)

