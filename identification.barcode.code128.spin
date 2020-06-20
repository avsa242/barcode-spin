{                                                                                                           --------------------------------------------
    Filename: identification.barcode.code128.spin
    Author: Jesse Burt
    Description: Library to generate barcodes from messages
    Copyright (c) 2020
    Started Jun 20, 2020
    Updated Jun 20, 2020
    See end of file for terms of use.
    --------------------------------------------
}
CON

' Control symbols (offsets within code128dict)
    A_FNC3      = 96
    B_FNC3      = 96
    A_FNC2      = 97
    B_FNC2      = 97
    B_FNC4      = 100
    A_FNC4      = 101
    FNC1        = 102
    STARTCODE_A = 103
    STARTCODE_B = 104
    STARTCODE_C = 105
    STOP        = 106

VAR

    word    _barcode[32]

PUB AtoC128B(ptr_msg, len) | idx, weight, curr_sym, cksum
' Convert ASCII message to CODE128 (Code set B)
'   Valid values:
'       ptr_msg: Pointer to message to generate CODE128 from
'       len: Length of message
'   Returns:
'       LSW [0..15]: Pointer to generated CODE128 data
'       MSB [24..31]: Word length of generated CODE128 data
    cksum := 0

    weight := 1                                                 ' Weight used as a multiplier for each data byte to calculate checksum byte: 1st two symbols' weight is 1
    curr_sym := STARTCODE_B
    cksum += curr_sym * weight                                  ' Accumulate sum of message bytes for eventual checksum
    _barcode[0] := code128dict[STARTCODE_B] >< 11               ' First symbol in the barcode is the Code B Start symbol
'                                                                   Reverse bits so the data can be used left-to-right when displaying the barcode
    repeat idx from 0 to len                                    ' Step through input data
        case idx
            0:
                weight := 1
                curr_sym := byte[ptr_msg][idx]-32               ' Calc offset within symbol table for ASCII characters
                cksum += curr_sym * weight
                _barcode[idx+1] := code128dict[curr_sym] >< 11

            1..len:
                weight++                                        ' Weight increments for each subsequent byte of the message

                curr_sym := byte[ptr_msg][idx]-32
                cksum += curr_sym * weight
                _barcode[idx+1] := code128dict[curr_sym] >< 11

    _barcode[++idx] := code128dict[(cksum // 103)] >< 11        ' Checksum is sum of all symbols * weights, modulo 103

    _barcode[++idx] := code128dict[STOP] >< 11                  ' Last symbol is the Stop symbol

    return @_barcode | (idx << 24)                              ' Return address of generated CODE128, plus the word length in the MSB

DAT
' CODE128 Symbology
    code128dict     word    %11011001100    ' 32 / SPACE
                    word    %11001101100
                    word    %11001100110
                    word    %10010011000
                    word    %10010001100
                    word    %10001001100
                    word    %10011001000
                    word    %10011000100
                    word    %10001100100
                    word    %11001001000
                    word    %11001000100
                    word    %11000100100
                    word    %10110011100
                    word    %10011011100
                    word    %10011001110
                    word    %10111001100
                    word    %10011101100
                    word    %10011100110
                    word    %11001110010
                    word    %11001011100
                    word    %11001001110
                    word    %11011100100
                    word    %11001110100
                    word    %11101101110
                    word    %11101001100
                    word    %11100101100
                    word    %11100100110
                    word    %11101100100
                    word    %11100110100
                    word    %11100110010
                    word    %11011011000
                    word    %11011000110
                    word    %11000110110
                    word    %10100011000
                    word    %10001011000
                    word    %10001000110
                    word    %10110001000
                    word    %10001101000
                    word    %10001100010
                    word    %11010001000
                    word    %11000101000
                    word    %11000100010
                    word    %10110111000
                    word    %10110001110
                    word    %10001101110
                    word    %10111011000
                    word    %10111000110
                    word    %10001110110
                    word    %11101110110
                    word    %11010001110
                    word    %11000101110
                    word    %11011101000
                    word    %11011100010
                    word    %11011101110
                    word    %11101011000
                    word    %11101000110
                    word    %11100010110
                    word    %11101101000
                    word    %11101100010
                    word    %11100011010
                    word    %11101111010
                    word    %11001000010
                    word    %11110001010
                    word    %10100110000
                    word    %10100001100
                    word    %10010110000
                    word    %10010000110
                    word    %10000101100
                    word    %10000100110
                    word    %10110010000
                    word    %10110000100
                    word    %10011010000
                    word    %10011000010
                    word    %10000110100
                    word    %10000110010
                    word    %11000010010
                    word    %11001010000
                    word    %11110111010
                    word    %11000010100
                    word    %10001111010
                    word    %10100111100
                    word    %10010111100
                    word    %10010011110
                    word    %10111100100
                    word    %10011110100
                    word    %10011110010
                    word    %11110100100
                    word    %11110010100
                    word    %11110010010
                    word    %11011011110
                    word    %11011110110
                    word    %11110110110
                    word    %10101111000
                    word    %10100011110
                    word    %10001011110
                    word    %10111101000
                    word    %10111100010
                    word    %11110101000
                    word    %11110100010
                    word    %10111011110
                    word    %10111101110
                    word    %11101011110
                    word    %11110101110
                    word    %11010000100
                    word    %11010010000
                    word    %11010011100
                    word    %11000111010

{
    --------------------------------------------------------------------------------------------------------
    TERMS OF USE: MIT License

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
    associated documentation files (the "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the
    following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial
    portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    --------------------------------------------------------------------------------------------------------
}
