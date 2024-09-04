//:============================================================================================
//: MIT License
//:
//: Copyright (c) 2024 7r35c0
//:
//: Permission is hereby granted, free of charge, to any person obtaining a copy
//: of this software and associated documentation files (the "Software"), to deal
//: in the Software without restriction, including without limitation the rights
//: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//: copies of the Software, and to permit persons to whom the Software is
//: furnished to do so, subject to the following conditions:
//:
//: The above copyright notice and this permission notice shall be included in all
//: copies or substantial portions of the Software.
//:
//: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//: SOFTWARE.
//:============================================================================================

// Tested with zig version 0.13.0 on Linux Fedora 39.

const std = @import("std");

const count_digit_iterative = @import("count_digit_iterative.zig");
const count_digit_logarithmic = @import("count_digit_logarithmic.zig");
const count_digit_lookup = @import("count_digit_lookup.zig");
const count_digit_recursive = @import("count_digit_recursive.zig");
const count_digit_stringify = @import("count_digit_stringify.zig");
const count_digit_switcher = @import("count_digit_switcher.zig");
const nearest_integer_type = @import("nearest_integer_type.zig");

pub const countDigitIterative = count_digit_iterative.countDigitIterative;
pub const countDigitLogarithmic = count_digit_logarithmic.countDigitLogarithmic;
pub const countDigitLookup = count_digit_lookup.countDigitLookup;
pub const countDigitRecursive = count_digit_recursive.countDigitRecursive;
pub const countDigitStringify = count_digit_stringify.countDigitStringify;
pub const countDigitSwitcher = count_digit_switcher.countDigitSwitcher;
pub const NearestIntegerType = nearest_integer_type.NearestIntegerType;

//+============================================================================================
//+ Tests: above imports
//+============================================================================================

test "algore" {
    const expect = std.testing.expectEqual;

    try expect(1, countDigitIterative(0));
    try expect(1, countDigitIterative(0.0));

    try expect(1, countDigitLogarithmic(0));
    try expect(1, countDigitLogarithmic(0.0));

    try expect(1, countDigitLookup(0));
    try expect(1, countDigitLookup(0.0));

    try expect(1, countDigitRecursive(0));
    try expect(1, countDigitRecursive(0.0));

    try expect(1, countDigitStringify(0));
    try expect(1, countDigitStringify(0.0));

    try expect(1, countDigitSwitcher(0));
    try expect(1, countDigitSwitcher(0.0));

    try expect(i1, NearestIntegerType(-1));
    try expect(u0, NearestIntegerType(0));
    try expect(u1, NearestIntegerType(1));
}

test {
    std.testing.refAllDecls(@This());
}
