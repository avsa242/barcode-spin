{
    --------------------------------------------
    Filename: barcode.code39.spin
    Author: Jesse Burt
    Description: CODE39 Barcode library
        Encode CODE39 from ASCII messages
        Decode CODE39 to ASCII messages
    Copyright (c) 2023
    Started Jun 21, 2020
    Updated Jul 27, 2023
    See end of file for terms of use.
    --------------------------------------------
}
CON

    { limits }
    SYMBOL_LEN      = 12
    MAX_BARCODE_LEN = 32
    MAX_ASCII_LEN   = 64

    { Control symbols (offsets within code39dict) }
    SHIFT1          = 39
    SHIFT2          = 40
    SHIFT3          = 41
    SHIFT4          = 42
    STARTSTOP       = 43

OBJ

    { virtual display driver object }
    disp=   DISP_DRIVER

    char:    "char.type"

VAR

    { display driver instance }
    long _drv

    { colors, position, dimensions }
    long _bar_color, _spc_color
    word _sx, _sy, _width, _height
    word _ptr_msg

    { barcode data }
    word _barcode[MAX_BARCODE_LEN]
    byte _ascii[MAX_ASCII_LEN]
    byte _cksum_enabled
    byte _msg_len
    byte _last_bclen

PUB bind = attach_to_driver
PUB attach = attach_to_driver
PUB attach_to_driver(ptr_drv)
' Attach to a display driver object
    _drv := ptr_drv

pub atoc39 = ascii_to_code39
PUB ascii_to_code39(): bc_len | cksum, curr_sym, idx
' Encode CODE39 data from ASCII message
'   Valid values:
'       ptr_msg: Pointer to message to generate CODE39 from (0..9, A-Z, "-", ".", " ")
'       len: Length of message
'   Returns:
'       LSW [0..15]: Pointer to generated CODE39 data
'       MSW [16..24]: Word length of generated CODE39 data
    cksum := 0
    _barcode[0] := (code39dict[STARTSTOP] >< SYMBOL_LEN)

    repeat idx from 0 to _msg_len-1
        curr_sym := byte[_ptr_msg][idx]
        if ( char.isalpha(curr_sym) )
            curr_sym -= 55
        elseif ( char.isdigit(curr_sym) )
            curr_sym -= 48
        cksum += curr_sym
        _barcode[idx+1] := (code39dict[curr_sym] >< SYMBOL_LEN)

    if ( checksum_enabled() )
        _barcode[++idx] := (code39dict[(cksum // 43)] >< SYMBOL_LEN)
    _barcode[++idx] := (code39dict[STARTSTOP] >< SYMBOL_LEN)
    _last_bclen := idx
    return @_barcode | (idx << 16)

PUB checksum_enabled(enabled=-2)
' Enable checksum byte in generated barcodes
'   Valid values: TRUE (-1 or 1), FALSE (0)
'   Any other value returns the current setting
    case ||(enabled)
        0, 1:
            _cksum_enabled := ||(enabled)
        OTHER:
            ifnot ( lookdown(_cksum_enabled: 0, 1) )
                _cksum_enabled := FALSE
            return _cksum_enabled

PUB c39toa = code39_to_ascii
PUB code39_to_ascii(ptr_bar) | sym, idx, stst
' Decode CODE39 data to ASCII message
'   Valid values:
'       ptr_bar: Pointer to barcode data to generate ASCII message from
'   Returns:
'       LSW [0..15]: Pointer to generated ASCII message
'       MSW [16..24]: Word length of generated message
'   NOTE: Decoded data is raw, i.e., includes START/STOP symbols (*), and checksum
'   NOTE: Invalid symbols in barcode data will be decoded to '?'
    idx := curr_sym := stst := 0

    repeat
        sym := (word[ptr_bar][idx] >< SYMBOL_LEN)
        _ascii[idx] := lookup_sym(curr_sym)     ' Decode to ASCII

        if ( _ascii[idx] == "*" )               ' Found a START/STOP marker
            stst++                              ' Increment start/stop counter

        if ( stst == 2 )                        ' Counter == 2 means end of barcode
            _ascii[++idx] := 0                  ' Zero terminate
            quit                                ' Stop further processing

        idx++
    while (idx < MAX_ASCII_LEN)
    return ( @_ascii | ((idx+1) << 16) )

PUB conv_and_draw() | x, sy, ey, bit, ch, idx, msg
' Convert a message to CODE39 and draw the barcode
'   Returns: length of barcode drawn
    x := _sx
    sy := _sy
    ey := sy+_height

    ascii_to_code39()                           ' convert the message in memory
    repeat idx from 0 to _last_bclen
        ch := _barcode[idx]
        repeat bit from 0 to SYMBOL_LEN-1
            if ( ch & 1 )                       ' read LSB
                disp[_drv].line(x, sy, x, ey, _bar_color)
                x++
            else
                disp[_drv].line(x, sy, x, ey, _spc_color)
                x++
            ch ->= 1                            ' prep next bit

        x++                                     ' next bar
    return (x-_sx)

PUB draw(): l | x, sy, ey, bit, ch, idx, msg
' Draw the last formed CODE39 barcode
'   Returns: length of barcode drawn
    x := _sx
    sy := _sy
    ey := sy+_height

    repeat idx from 0 to _last_bclen
        ch := _barcode[idx]
        repeat bit from 0 to SYMBOL_LEN-1
            if ( ch & 1 )                       ' LSB set? draw bar
                disp[_drv].line(x, sy, x, ey, _bar_color)
                x++
            else                                ' otherwise, draw space
                disp[_drv].line(x, sy, x, ey, _spc_color)
                x++
            ch ->= 1                            ' prep next bit

        x++                                     ' next bar
    return (x-_sx)

PUB lookup_sym(sym) | idx
' Decode barcode data to ASCII, given a CODE39 word/symbol
'   Returns: ASCII value of decoded symbol, or '?' if invalid
    repeat idx from 0 to 43
        if ( sym == code39dict[idx] )           ' Found a match:
            case idx
                0..9:                           ' Numbers
                    return idx+48
                10..35:                         ' Letters
                    return idx+55
                36..43:                         ' Symbols
                    return lookupz(idx-36: "-", ".", " ", "$", "/", "+", "%", "*")

    return "?"                                  ' Invalid - not found in the table

pub set_colors(bc, sc)
' Set barcode colors
'   bc: bar color
'   sc: space color
    _bar_color := bc
    _spc_color := sc

pub set_msg(ptr_msg, len)
' Set message to generate barcode from
    _ptr_msg := ptr_msg
    _msg_len := len

pub set_pos(x, y)
' Set position of barcode
    _sx := x
    _sy := y

pub set_pos_dims(x, y, w, h)
' Set position and dimensions of barcode
    _sx := x
    _sy := y
    _width := w
    _height := h

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

DAT
{
Copyright 2023 Jesse Burt

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
}

