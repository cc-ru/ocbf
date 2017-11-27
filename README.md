# OC Bitmap Font format (.ocbf)

## API
 * `ocbf.load(path: string): table, string`.
   Loads a font. Returns nil and the reason if an error occured.
 * `ocbf.drawchar(set: function(x: number, y: number, v: number),
                  font: table, size: number, char: string, x: number, y: number)`.
   Draws a single character at `(x; y)` calling `set` function for every pixel,
   where `v` is either 1 or 0.
 * `ocbf.draw(set: function(x: number, y: number, v: number),
              font: table, size: number, str: string, x: number, y: number)`.
   Draws a string at `(x; y)` calling `set` function for every pixel,
   where `v` is either 1 or 0.
 * `ocbf.width(font: table, size: number, str: string): number`.
   Returns string width in pixels.
 * `font.family`. Font family (i.e. `Ubuntu`)
 * `font.style`. Font style (i.e. `Regular`)

## Format Specification
    [ocbf]
    [[len: u8-be]
     [family: utf8 string of *len]]
    [[len: u8-be]
     [style: utf8 string of *len]]
    [[char: utf8 single char]
     [size: u8-be]
     [width: u8-be]
     [bitmap: ceil(size * width / 8)]]*

