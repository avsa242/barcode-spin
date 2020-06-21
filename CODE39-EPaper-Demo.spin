{
    --------------------------------------------
    Fimsglename: CODE39-EPaper-Demo.spin
    Author: Jesse Burt
    Description: Demo of the CODE39 Barcode generator,
        rendered on an IL3820-based E-Paper display
    Copyright (c) 2020
    Started Jun 21, 2020
    Updated Jun 21, 2020
    See end of file for terms of use.
    --------------------------------------------
}

CON

    _clkmode    = cfg#_clkmode
    _xinfreq    = cfg#_xinfreq

' -- User-modifiable constants
    LED         = cfg#LED1
    SER_RX      = 31
    SER_TX      = 30
    SER_BAUD    = 115_200

    DIN_PIN     = 11
    CLK_PIN     = 10
    CS_PIN      = 9
    DC_PIN      = 8
    RST_PIN     = 7
    BUSY_PIN    = 6

    WIDTH       = 128
    HEIGHT      = 296
' --

    XMAX        = WIDTH-1
    YMAX        = HEIGHT-1
    BUFF_SZ     = WIDTH * ((HEIGHT + 7) / 8)

OBJ

    cfg     : "core.con.boardcfg.activityboard"
    ser     : "com.serial.terminal.ansi"
    time    : "time"
    io      : "io"
    epaper  : "display.epaper.il3820.spi"
    fnt     : "font.5x8"
    code39 : "identification.barcode.code39"

VAR

    word _y
    byte _framebuff[BUFF_SZ]
    byte _ser_cog

PUB Main | msg[8], i, msglen, bclen, ptr_bar

    Setup
    epaper.BGColor($FF)
    epaper.Clear
    epaper.FGColor(0)
    ser.newline

    _y := 16                                                    ' Starting y-coordinate for barcode
    msglen := 0

    msg := string("PROPELLER")                                  ' Message to encode
    msglen := strsize(msg)
    ptr_bar := code39.AtoC39(msg, msglen-1)                     ' Generate the barcode, get pointer to the barcode data
    bclen := ptr_bar >> 24                                      '   and the length (returned in MSB), in number of words

    repeat i from 0 to bclen
        RenderBarcode(word[ptr_bar][i])

    repeat until epaper.DisplayReady                            ' Wait for the display to be ready
    epaper.Update                                               ' Send the display buffer to the display

    FlashLED (LED, 100)

PUB RenderBarcode(ch) | bit, margin

    margin := 10
'    epaper.line(XMAX, _y-1, XMAX-20, _y-1, 0)                   ' Symbol left margin indicator

    repeat bit from 0 to code39#SYMBOL_LEN-1
        if ch & 1
            epaper.line(margin, _y, XMAX-MARGIN, _y, 0)         ' Bar
            _y++
        else
            epaper.line(margin, _y, XMAX-MARGIN, _y, 1)         ' Space
            if bit < code39#SYMBOL_LEN-1
                _y++
        ch ->= 1

'    epaper.line(XMAX, _y+1, XMAX-20, _y+1, 0)                   ' Symbol right margin indicator

    _y++                                                        ' Advance right one col after symbol

PUB Setup

    repeat until ser.StartRXTX (SER_RX, SER_TX, 0, SER_BAUD)
    time.msleep(100)
    ser.Clear
    ser.Str(string("Serial terminal started", ser#CR, ser#LF))
    if epaper.Start (CS_PIN, CLK_PIN, DIN_PIN, DC_PIN, RST_PIN, BUSY_PIN, WIDTH, HEIGHT, @_framebuff)
        ser.Str (string("IL3820 driver started"))
        epaper.FontAddress(fnt.BaseAddr)
        epaper.FontSize(6, 7)
    else
        ser.Str (string("IL3820 driver failed to start - halting"))
        epaper.Stop
        time.MSleep (500)
        ser.Stop
        FlashLED (LED, 500)

#include "lib.utility.spin"

DAT
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
