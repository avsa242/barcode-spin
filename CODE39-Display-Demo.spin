{
    --------------------------------------------
    Fimsglename: CODE39-EPaper-Demo.spin
    Author: Jesse Burt
    Description: Demo of the CODE39 Barcode generator
        * render on display (driver chosen at build-time; see below)
    Copyright (c) 2023
    Started Jun 21, 2020
    Updated Jul 30, 2023
    See end of file for terms of use.
    --------------------------------------------

    NOTE: The build symbol DISP_DRIVER must be set to a display driver filename

    Example:
        flexspin -DDISP_DRIVER=\"display.epaper.il3820\" CODE128-Display-Demo.spin

}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-modifiable constants
    SER_BAUD    = 115_200
' --

OBJ

    cfg:    "boardcfg.flip"
    ser:    "com.serial.terminal.ansi"
    time:   "time"
    fnt:    "font.5x8"
    code39: "barcode.code39"
    disp:   DISP_DRIVER | WIDTH=256, HEIGHT=64, CS=0, SCK=1, MOSI=2, DC=3, RST=-1
    ' NOTE: E-paper displays (e.g. IL3820, IL3897 also use a BUSY pin)

DAT

    { the message to encode:
        CODE39 symbology allows for any ASCII value 48..57, 65..90, 32, 45, 46
        (upper-case letters, numbers, space, '-', '.') }
    msg    byte "PROPELLER", 0

PUB main() | l, text_x, text_y

    setup()

    disp.defaults()

    { NOTE: it's recommended to keep the colors set as (or change to, if necessary)
        black foreground on white background }
    disp.bgcolor(disp.MAX_COLOR)                ' typically white
    disp.fgcolor(0)                             ' typically black

    disp.clear()

    code39.attach(@disp)                        ' bind to the display driver chosen above
    code39.checksum_enabled(false)
    code39.set_pos_dims(10, 10, 0, 43)          ' position the barcode
    code39.set_colors(0, 15)                    ' set barcode bar, space colors
    code39.set_msg(@msg, strsize(@msg))         ' point the barcode object to the message to encode
    l := code39.conv_and_draw()                 ' convert and draw it

    { position the message text at about the bottom center of the barcode }
    text_x := (l / 2) - ((strsize(@msg)/2) * disp.font_width())
    text_y := code39._bottom - disp.font_height()
    disp.pos_xy(text_x, text_y)
    disp.str(@msg)
    disp.show()

    repeat

PUB setup()

    ser.start(SER_BAUD)
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

