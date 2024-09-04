<!--
:===============================================================================
: MIT License
:
: Copyright (c) 2024 7r35c0
:
: Permission is hereby granted, free of charge, to any person obtaining a copy
: of this software and associated documentation files (the "Software"), to deal
: in the Software without restriction, including without limitation the rights
: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
: copies of the Software, and to permit persons to whom the Software is
: furnished to do so, subject to the following conditions:
:
: The above copyright notice and this permission notice shall be included in all
: copies or substantial portions of the Software.
:
: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
: SOFTWARE.
:===============================================================================
 -->

## LookupTable()

Tested with zig version 0.13.0 on Linux Fedora 39.

### About

Generates for a number of `bits`, the lookup table used in `count_digit_lookup` algorithm.

Supported bits range, less than 1024.

### Implementation

A zig language version of [generate.py](https://github.com/lemire/Code-used-on-Daniel-Lemire-s-blog/blob/master/2021/06/03/generate.py) file.

As an example usage, `demo/generate.zig` uses generator and saves the results
to `LookupTable.txt` file, in project root.

### Examples

```zig
const std = @import("std");

const LookupTable = @import("generate_lookup_table").LookupTable;

pub fn main() !void {
    const table = LookupTable(128).generate();

    const file = try std.fs.cwd().createFile(
        "LookupTable.txt",
        .{
            .read = true,
            .truncate = true,
        },
    );
    defer file.close();

    try file.writer().print("{}\n", .{table});
}
```
