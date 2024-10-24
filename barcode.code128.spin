{
----------------------------------------------------------------------------------------------------
    Filename:       barcode.code128.spin
    Description:    Object for building CODE128 barcode data from ASCII
    Author:         Jesse Burt
    Started:        Jun 20, 2020
    Updated:        Oct 24, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    { limits }
    SYMBOL_LEN      = 11
    MAX_BARCODE_LEN = 32
    MAX_ASCII_LEN   = 64

    { Control symbols (offsets within code128dict) }
    FUNC3_A         = 96
    FUNC3_B         = 96
    FUNC2_A         = 97
    FUNC2_B         = 97
    SHIFT_B         = 98
    SHIFT_A         = 98
    CODE_C          = 99
    CODE_B          = 100                       ' code B
    FUNC_4B         = 100                       '   or func 4
    CODE_A          = 101                       ' code A
    FUNC_4A         = 101                       '   or func 4
    FUNC1           = 102
    START_A         = 103
    START_B         = 104
    START_C         = 105
    STOP            = 106
    STOP_REV        = 107
    STOP_PATT       = 108


OBJ

    { virtual display driver object }
    disp=   DISP_DRIVER


VAR

    { display driver instance }
    long _drv

    { colors, position, dimensions }
    long _bar_color, _spc_color
    word _sx, _sy, _width, _height, _right, _bottom
    word _ptr_msg

    { barcode data }
    word _barcode[MAX_BARCODE_LEN]
    byte _ascii[MAX_ASCII_LEN]
    byte _cksum_enabled
    byte _msg_len
    byte _last_bclen


pub bind = attach_to_driver
pub attach = attach_to_driver
pub attach_to_driver(ptr_drv)
' Attach to a display driver object
    _drv := ptr_drv


PUB atoc128b = ascii_to_code128b
PUB ascii_to_code128b() | cksum, sym, idx, weight
' Encode CODE128 (Code set B) data from ASCII message
'   Valid values:
'       ptr_msg: Pointer to message to generate CODE128 from (ASCII 32..127)
'       len: Length of message
'   Returns:
'       LSW [0..15]: Pointer to generated CODE128 data
'       MSB [24..31]: Word length of generated CODE128 data
    cksum := 0

    weight := 1                                 ' init multiplier for checksum calc
    sym := START_B
    cksum += sym * weight                       ' checksum

    { code set B start symbol; also, reverse the bits so they're in displayable order }
    _barcode[0] := code128dict[START_B] >< SYMBOL_LEN

    { convert each byte of input data to a code128 (code set B) symbol }
    repeat idx from 0 to _msg_len-1
        sym := codeset_b_lookup_symbol(byte[_ptr_msg][idx])
        if ( idx == 0 )
            weight := 1
        elseif ( (idx => 1) and (idx =< _msg_len) )
            weight++
        cksum += sym * weight
        _barcode[idx+1] := code128dict[sym] >< SYMBOL_LEN

    { checksum: sum all symbols * weights, modulo 103
        NOTE: The checksum is _mandatory_ with code128 }
    _barcode[++idx] := code128dict[(cksum // 103)] >< SYMBOL_LEN

    { stop symbol }
    _barcode[++idx] := code128dict[STOP] >< SYMBOL_LEN

    { 2-module bar: _always_ at the end, regardless of a left-to-right or right-to-left barcode }
    _barcode[++idx] := %11

    _last_bclen := idx
    return @_barcode | (idx << 24)              ' address of generated CODE128 | word length


pub conv_and_draw(): l
' Convert a message to CODE128 and draw the barcode
'   Returns: length of barcode drawn
    ascii_to_code128b()
    l := draw()


pub codeset_b_lookup_symbol(ascii_val): offs
' Convert an ASCII value to an offset within the code128 dictionary (code set B)
    return (ascii_val - 32)


pub draw() | x, sy, ey, bit, ch, idx
' Draw the last formed barcode
'   Returns: length of barcode drawn
    x := _sx
    sy := _sy
    ey := sy+_height

    repeat idx from 0 to _last_bclen
        ch := _barcode[idx]
        repeat bit from 0 to 10
            if ( ch & 1 )                       ' LSB set? draw bar
                disp[_drv].line(x, sy, x, ey, _bar_color)
                x++
            else                                ' otherwise, draw space
                disp[_drv].line(x, sy, x, ey, _spc_color)
                if ( bit < 10 )
                    x++
            ch ->= 1                            ' prep next bit
        x++                                     ' next bar
    return (x-_sx)


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
    _right := _sx + _width
    _bottom := _sy + _height


DAT
' CODE128 Symbology
    code128dict     word    %11011001100    ' 0 / SPACE
                    word    %11001101100
                    word    %11001100110
                    word    %10010011000
                    word    %10010001100
                    word    %10001001100
                    word    %10011001000
                    word    %10011000100
                    word    %10001100100
                    word    %11001001000
                    word    %11001000100    ' 10
                    word    %11000100100
                    word    %10110011100
                    word    %10011011100
                    word    %10011001110
                    word    %10111001100
                    word    %10011101100
                    word    %10011100110
                    word    %11001110010
                    word    %11001011100
                    word    %11001001110    ' 20
                    word    %11011100100
                    word    %11001110100
                    word    %11101101110
                    word    %11101001100
                    word    %11100101100
                    word    %11100100110
                    word    %11101100100
                    word    %11100110100
                    word    %11100110010
                    word    %11011011000    ' 30
                    word    %11011000110
                    word    %11000110110
                    word    %10100011000
                    word    %10001011000
                    word    %10001000110
                    word    %10110001000
                    word    %10001101000
                    word    %10001100010
                    word    %11010001000
                    word    %11000101000    ' 40
                    word    %11000100010
                    word    %10110111000
                    word    %10110001110
                    word    %10001101110
                    word    %10111011000
                    word    %10111000110
                    word    %10001110110
                    word    %11101110110
                    word    %11010001110
                    word    %11000101110    ' 50
                    word    %11011101000
                    word    %11011100010
                    word    %11011101110
                    word    %11101011000
                    word    %11101000110
                    word    %11100010110
                    word    %11101101000
                    word    %11101100010
                    word    %11100011010
                    word    %11101111010    ' 60
                    word    %11001000010
                    word    %11110001010
                    word    %10100110000
                    word    %10100001100
                    word    %10010110000
                    word    %10010000110
                    word    %10000101100
                    word    %10000100110
                    word    %10110010000
                    word    %10110000100    ' 70
                    word    %10011010000
                    word    %10011000010
                    word    %10000110100
                    word    %10000110010
                    word    %11000010010
                    word    %11001010000
                    word    %11110111010
                    word    %11000010100
                    word    %10001111010
                    word    %10100111100    ' 80
                    word    %10010111100
                    word    %10010011110
                    word    %10111100100
                    word    %10011110100
                    word    %10011110010
                    word    %11110100100
                    word    %11110010100
                    word    %11110010010
                    word    %11011011110
                    word    %11011110110    ' 90
                    word    %11110110110
                    word    %10101111000
                    word    %10100011110
                    word    %10001011110
                    word    %10111101000
                    word    %10111100010    ' 96 (FNC3/FNC3/96)
                    word    %11110101000    ' 97 (FNC2/FNC2/97)
                    word    %11110100010    ' 98 (SHIFT B/SHIFT A/98)
                    word    %10111011110    ' 99 (CODE C/CODE C/99)
                    word    %10111101110    ' 100 (CODE B/FNC 4/CODE B)
                    word    %11101011110    ' 101 (FNC 4/CODE A/CODE A)
                    word    %11110101110    ' 102 (FNC 1/FNC 1/FNC 1)
                    word    %11010000100    ' 103 (START CODE A)
                    word    %11010010000    ' 104 (START CODE B)
                    word    %11010111000    ' 105 (START CODE C)
                    word    %11000111010    ' 106 (STOP)
                    word    %11010111000    ' 107 (REVERSE STOP)
                    word    %110001101011   ' 108 (STOP PATTERN)


DAT
{
Copyright 2024 Jesse Burt

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

