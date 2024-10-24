{
----------------------------------------------------------------------------------------------------
    Filename:       CODE128-EPaper-Demo.spin
    Description:    Demo of the CODE128 Barcode generator
        * render on display (driver chosen at build-time; see below)
    Author:         Jesse Burt
    Started:        Jun 20, 2020
    Updated:        Oct 24, 2024
    Copyright (c) 2024 - See end of file for terms of use.
----------------------------------------------------------------------------------------------------
}

' Uncomment one of the below display drivers
#define DISP_DRIVER "display.epaper.il3820"
'#define DISP_DRIVER "display.epaper.il3897"
#pragma exportdef(DISP_DRIVER)


CON

    _clkmode    = xtal1+pll16x
    _xinfreq    = 5_000_000


OBJ

    ser:    "com.serial.terminal.ansi" | SER_BAUD=115_200
    disp:   DISP_DRIVER | WIDTH=256, HEIGHT=64, CS=0, SCK=1, MOSI=2, DC=3, RST=-1, BUSY=5
    ' NOTE: E-paper displays (e.g. IL3820, IL3897 also use a BUSY pin)

    time:   "time"
    fnt:    "font.5x8"
    code128:"barcode.code128"


DAT

    { the message to encode:
        CODE128 symbology allows for any ASCII value 32..127 (upper/lower-case letters, numbers,
        punctuation) }
    msg    byte "Propeller", 0


PUB main() | l, text_x, text_y

    setup()

    disp.defaults()

    { NOTE: it's recommended to keep the colors set as (or change to, if necessary)
        black foreground on white background } 
    disp.bgcolor(disp.MAX_COLOR)                ' typically white
    disp.fgcolor(0)                             ' typically black

    disp.clear()

    code128.attach(@disp)                       ' bind to the display driver chosen above
    code128.set_pos_dims(10, 10, 0, 43)         ' position the barcode
    code128.set_colors(0, 15)                   ' set barcode bar, space colors
    code128.set_msg(@msg, strsize(@msg))        ' point the barcode object to the message to encode
    l := code128.conv_and_draw()                ' convert and draw it

    { position the message text at about the bottom center of the barcode }
    text_x := (l / 2) - ((strsize(@msg)/2) * disp.font_width())
    text_y := code128._bottom - disp.font_height()
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

