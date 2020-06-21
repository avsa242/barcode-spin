{                                                                                                           --------------------------------------------
    Filename: identification.barcode.code39.spin
    Author: Jesse Burt
    Description: CODE39 Barcode library
        Encode CODE39 from ASCII messages
        Decode CODE39 to ASCII messages
    Copyright (c) 2020
    Started Jun 21, 2020
    Updated Jun 21, 2020
    See end of file for terms of use.
    --------------------------------------------
}
CON

    SYMBOL_LEN      = 12
    MAX_BARCODE_LEN = 32                                    ' XXX Arbitrary
    MAX_ASCII_LEN   = 64                                    ' XXX Arbitrary

' Control symbols (offsets within code39dict)
    SHIFT1          = 39
    SHIFT2          = 40
    SHIFT3          = 41
    SHIFT4          = 42
    STARTSTOP       = 43

VAR

    word    _barcode[MAX_BARCODE_LEN]
    byte    _ascii[MAX_ASCII_LEN]
    byte    _cksum_enabled

PUB AtoC39(ptr_msg, len) | cksum, curr_sym, idx, tmp
' Encode CODE39 data from ASCII message
'   Valid values:
'       ptr_msg: Pointer to message to generate CODE39 from (0..9, A-Z, "-", ".", " ")
'       len: Length of message
'   Returns:
'       LSW [0..15]: Pointer to generated CODE39 data
'       MSB [24..31]: Word length of generated CODE39 data
    cksum := 0
    _barcode[0] := code39dict[STARTSTOP] >< SYMBOL_LEN

    repeat idx from 0 to len-1
        curr_sym := byte[ptr_msg][idx]
        if lookdown(curr_sym: 65..91)
            curr_sym -= 55
        elseif lookdown(curr_sym: 48..57)
            curr_sym -= 48
        cksum += curr_sym
        _barcode[idx+1] := code39dict[curr_sym] >< SYMBOL_LEN

    if ChecksumEnabled(-2)
        _barcode[++idx] := code39dict[(cksum // 43)] >< SYMBOL_LEN
    _barcode[++idx] := code39dict[STARTSTOP] >< SYMBOL_LEN
    return @_barcode | (idx << 24)

PUB C39toA(ptr_bar) | curr_sym, idx, stst
' Decode CODE39 data to ASCII message
'   Valid values:
'       ptr_bar: Pointer to barcode data to generate ASCII message from
'   Returns:
'       LSW [0..15]: Pointer to generated ASCII message
'       MSB [24..31]: Word length of generated message
'   NOTE: Decoded data is raw, i.e., includes START/STOP symbols (*), and checksum
'   NOTE: Invalid symbols in barcode data will be decoded to '?'
    idx := curr_sym := stst := 0

    repeat
        curr_sym := word[ptr_bar][idx] >< SYMBOL_LEN        ' Fetch current symbol from barcode data
        _ascii[idx] := lookupSym(curr_sym)                  ' Decode to ASCII

        if _ascii[idx] == "*"                               ' Found a START/STOP marker
            stst++                                          ' Increment start/stop counter

        if stst == 2                                        ' Counter == 2 means end of barcode
            _ascii[++idx] := 0                              ' Zero terminate
            quit                                            ' Stop further processing

        idx++
    while (idx < MAX_ASCII_LEN)
    return @_ascii | ((idx+1) << 24)

PUB ChecksumEnabled(enabled)
' Enable checksum byte in generated barcodes
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value returns the current setting
    case ||enabled
        0, 1:
            _cksum_enabled := ||enabled
        OTHER:
            ifnot lookdown(_cksum_enabled: 0, 1)
                _cksum_enabled := FALSE
            return _cksum_enabled

PUB LookupSym(sym) | symbol
' Decode barcode data to ASCII, given a CODE39 word/symbol
'   Returns: ASCII value of decoded symbol, or '?' if invalid
    repeat symbol from 0 to 43
        if sym == code39dict[symbol]                    ' Found a match:
            case symbol
                0..9:                                   ' Numbers
                    return symbol+48
                10..35:                                 ' Letters
                    return symbol+55
                36..43:                                 ' Symbols
                    return lookupz(symbol-36: "-", ".", " ", "$", "/", "+", "%", "*")

    return "?"                                          ' Invalid - not found in the table

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

'   Control codes
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
