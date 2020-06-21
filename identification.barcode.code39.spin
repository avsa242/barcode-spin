{                                                                                                           --------------------------------------------
    Filename: identification.barcode.code39.spin
    Author: Jesse Burt
    Description: Library to generate CODE39 barcodes from messages
    Copyright (c) 2020
    Started Jun 21, 2020
    Updated Jun 21, 2020
    See end of file for terms of use.
    --------------------------------------------
}
CON

    SYMBOL_LEN  = 12

' Control symbols (offsets within code39dict)
    SHIFT1      = 39
    SHIFT2      = 40
    SHIFT3      = 41
    SHIFT4      = 42
    STARTSTOP   = 43

VAR

    word    _barcode[32]

PUB AtoC39(ptr_msg, len) | curr_sym, idx, tmp
' Convert ASCII message to CODE39
'   Valid values:
'       ptr_msg: Pointer to message to generate CODE39 from
'       len: Length of message
'   Returns:
'       LSW [0..15]: Pointer to generated CODE39 data
'       MSB [24..31]: Word length of generated CODE39 data
    _barcode[0] := code39dict[STARTSTOP] >< SYMBOL_LEN

    repeat idx from 0 to len
        curr_sym := byte[ptr_msg][idx]
        if lookdown(curr_sym: 65..91)
            curr_sym -= 55
        elseif lookdown(curr_sym: 48..57)
            curr_sym -= 48
        _barcode[idx+1] := code39dict[curr_sym] >< SYMBOL_LEN

    _barcode[++idx] := code39dict[STARTSTOP] >< SYMBOL_LEN

    return @_barcode | (idx << 24)

DAT
' CODE39 Symbology
'   ASCII
    code39dict      word    %101001101101   ' 0 
                    word    %110100101011   ' 1
                    word    %101100101011   ' 2
                    word    %110110010101   ' 3
                    word    %101001101011   ' 4
                    word    %110100110101   ' 5
                    word    %101100110101   ' 6
                    word    %101001011011   ' 7
                    word    %110100101101   ' 8
                    word    %101100101101   ' 9
                    word    %110101001011   ' A
                    word    %101101001011   ' B
                    word    %110110100101   ' C
                    word    %101011001011   ' D
                    word    %110101100101   ' E
                    word    %101101100101   ' F
                    word    %101010011011   ' G
                    word    %110101001101   ' H
                    word    %101101001101   ' I
                    word    %101011001101   ' J
                    word    %110101010011   ' K
                    word    %101101010011   ' L
                    word    %110110101001   ' M
                    word    %101011010011   ' N
                    word    %110101101001   ' O
                    word    %101101101001   ' P
                    word    %101010110011   ' Q
                    word    %110101011001   ' R
                    word    %101101011001   ' S
                    word    %101011011001   ' T
                    word    %110010101011   ' U
                    word    %100110101011   ' V
                    word    %110011010101   ' W
                    word    %100101101011   ' X
                    word    %110010110101   ' Y
                    word    %100110110101   ' Z
                    word    %100101011011   ' -
                    word    %110010101101   ' .
                    word    %100110101101   ' SPACE

' Control codes
                    word    %100100100101   ' $ (SHIFT)
                    word    %100100101001   ' / (SHIFT)
                    word    %100101001001   ' + (SHIFT)
                    word    %101001001001   ' % (SHIFT)
                    word    %100101101101   ' * (START / STOP, _not_ asterisk)


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
