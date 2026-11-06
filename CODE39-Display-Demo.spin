{
----------------------------------------------------------------------------------------------------
    Filename:       CODE39-EPaper-Demo.spin
    Description:    Demo of the CODE39 Barcode generator
        * render on display (driver chosen at build-time; see below)
    Author:         Jesse Burt
    Started:        Oct 6, 2019
    Updated:        Nov 6, 2026
    Copyright (c) 2026 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

CON

    _clkmode    = xtal1+pll16x
    _xinfreq    = 5_000_000


OBJ

    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    disp:   "display.epaper.il3897" | WIDTH=122, HEIGHT=250, CS=0, SCK=1, MOSI=2, DC=3, RST=4, BUSY=5
'    disp:   "display.epaper.il3820" | WIDTH=128, HEIGHT=296, CS=0, SCK=1, MOSI=2, DC=3, RST=4, BUSY=5

    ' NOTE: E-paper displays (e.g. IL3820, IL3897 also use a BUSY pin)

    time:   "time"
    fnt:    "font.5x8"
    code39: "barcode.code39"


DAT

    ' the message to encode:
    msg    byte "PROPELLER", 0

    ' CODE39 symbology allows for any ASCII value 48..57, 65..90, 32, 45, 46
    '   (upper-case letters, numbers, space, '-', '.') }
    ' The barcode will be encoded as CODE39 Extended if the string contains any of the following:
    '   * lower-case letters
    '   * symbols !"#&'()*,:<=>?@[\]^_`{|}~
    '   * non-printable control codes (ASCII 31 and lower, and 127)


PUB main() | l, text_x, text_y

    setup()

'    disp.defaults()

'    disp.preset_2p13_bw()                       ' il3897

'    disp.set_rotation(0)                        ' 0, 90, 180, 270

    ' set screen background, text and barcode colors
    ' NOTE: it's recommended to use the display driver's black color on a white background
    disp.bgcolor(255)                           ' typically white
    disp.fgcolor(0)                             ' typically black
    code39.set_colors(0, 1)                     ' set barcode bar, space colors

    disp.clear()

    code39.set_line_func(@disp.line)            ' attach barcode obj to display's line() function

    code39.checksum_enabled(false)              ' optional CODE39 checksum

    ' position the barcode: x, y, width, height
    ' NOTE: Set the x position away from the extreme edge of the screen so the beginning of the
    '   barcode can be seen by the reader
    code39.set_pos_dims(5, 10, 0, 40)

    code39.set_msg(@msg, strsize(@msg))         ' point the barcode object to the message to encode
    l := code39.conv_and_draw()                 ' convert and draw it

    ' position the message text at about the bottom center of the barcode
    text_x := (code39._sx+(l/2) ) / 8
    text_y := (code39._bottom+disp.font_height()) / 8
    disp.pos_xy(text_x, text_y)
    disp.str(@msg)
    disp.show()

    repeat


PUB setup()

    ser.start()
    time.msleep(30)
    ser.clear()
    ser.strln(@"Serial terminal started")

    if ( disp.start() )
        ser.strln(@"Display driver started")
        disp.set_font(fnt.ptr(), fnt.setup())
        disp.char_attrs(disp.DRAWBG)
    else
        ser.strln(@"Display driver failed to start - halting")
        repeat


DAT
{
Copyright 2026 Jesse Burt

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

