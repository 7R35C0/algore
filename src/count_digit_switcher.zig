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

// The algorithm code is based on following sources:
// * CodeMaze - What’s the Best Way to Count the Digits in a Number
// https://code-maze.com/csharp-whats-the-best-way-to-count-the-number-of-digits-in-a-number/
// https://github.com/CodeMazeBlog/CodeMazeGuides/tree/main/numbers-csharp/CountNumberOfDigitsInANumber

// Tested with zig version 0.13.0 on Linux Fedora 39.

const std = @import("std");

/// Returns the number of digits for a `number`, using a switcher algorithm.
///
/// Supported number types and ranges:
/// * .ComptimeInt, .Int: ∓340282366920938463463374607431768211455
///   * min(i129) = -340282366920938463463374607431768211456 it is accepted to cover the type
/// * .ComptimeFloat, .Float:
///   * comptime_float: ∓10384593717069655257060992658440193
///   * f16:            ∓2049
///   * f32:            ∓16777217
///   * f64:            ∓9007199254740993
///   * f80:            ∓36893488147419103234
///   * f128:           ∓10384593717069655257060992658440193
///
/// Note that for float numbers, the type is important, for example 2050 as:
/// * f16: errors occur
/// * f32: returns 4, same as for any type greater than f16
///
/// Negative numbers are converted by the function to their absolute value.
pub fn countDigitSwitcher(number: anytype) usize {
    const value = checkError(number);

    return countSwitcher(value);
}

// check `number` types and ranges, return `@abs(number)` or errors occur
fn checkError(number: anytype) u128 {
    return switch (@typeInfo(@TypeOf(number))) {
        .ComptimeInt, .Int => blk: {
            const abs_num = @abs(number);
            const max_num = @abs(std.math.minInt(i129));

            if (abs_num > max_num) {
                std.log.err("unsupported number `{}` for type `{s}` - countDigitSwitcher() is not implemented for an @abs(number) > {} for this type", .{ number, @typeName(@TypeOf(number)), max_num });

                unreachable;
            }

            if (abs_num == max_num) {
                break :blk @as(u128, @intCast(std.math.maxInt(u128)));
            }

            break :blk @as(u128, @intCast(abs_num));
        },

        .ComptimeFloat, .Float => blk: {
            const abs_num = @abs(number);
            const max_num: u128 = switch (@sizeOf(@TypeOf(number))) {
                0 => 10384593717069655257060992658440193,
                else => switch (@typeInfo(@TypeOf(number)).Float.bits) {
                    16 => 2049,
                    32 => 16777217,
                    64 => 9007199254740993,
                    80 => 36893488147419103234,
                    128 => 10384593717069655257060992658440193,

                    // this error is redundant, but for a future f256 type it may be useful
                    else => {
                        @compileError("unsupported type `" ++ @typeName(@TypeOf(number)) ++ "` - countDigitSwitcher() is not implemented for this type");
                    },
                },
            };

            if (abs_num > max_num) {
                std.log.err("unsupported number `{}` for type `{s}` - countDigitSwitcher() is not implemented for an @abs(number) > {} for this type", .{ number, @typeName(@TypeOf(number)), max_num });

                unreachable;
            }

            break :blk @as(u128, @intFromFloat(@as(f128, @floatCast(abs_num))));
        },

        else => {
            @compileError("unsupported type `" ++ @typeName(@TypeOf(number)) ++ "` - countDigitSwitcher() is not implemented for this type");
        },
    };
}

// the switcher algorithm
fn countSwitcher(value: anytype) usize {
    return switch (value) {
        0...9 => 1,
        10...99 => 2,
        100...999 => 3,

        1_000...9_999 => 4,
        10_000...99_999 => 5,
        100_000...999_999 => 6,

        1_000_000...9_999_999 => 7,
        10_000_000...99_999_999 => 8,
        100_000_000...999_999_999 => 9,

        1_000_000_000...9_999_999_999 => 10,
        10_000_000_000...99_999_999_999 => 11,
        100_000_000_000...999_999_999_999 => 12,

        1_000_000_000_000...9_999_999_999_999 => 13,
        10_000_000_000_000...99_999_999_999_999 => 14,
        100_000_000_000_000...999_999_999_999_999 => 15,

        1_000_000_000_000_000...9_999_999_999_999_999 => 16,
        10_000_000_000_000_000...99_999_999_999_999_999 => 17,
        100_000_000_000_000_000...999_999_999_999_999_999 => 18,

        1_000_000_000_000_000_000...9_999_999_999_999_999_999 => 19,
        10_000_000_000_000_000_000...99_999_999_999_999_999_999 => 20,
        100_000_000_000_000_000_000...999_999_999_999_999_999_999 => 21,

        1_000_000_000_000_000_000_000...9_999_999_999_999_999_999_999 => 22,
        10_000_000_000_000_000_000_000...99_999_999_999_999_999_999_999 => 23,
        100_000_000_000_000_000_000_000...999_999_999_999_999_999_999_999 => 24,

        1_000_000_000_000_000_000_000_000...9_999_999_999_999_999_999_999_999 => 25,
        10_000_000_000_000_000_000_000_000...99_999_999_999_999_999_999_999_999 => 26,
        100_000_000_000_000_000_000_000_000...999_999_999_999_999_999_999_999_999 => 27,

        1_000_000_000_000_000_000_000_000_000...9_999_999_999_999_999_999_999_999_999 => 28,
        10_000_000_000_000_000_000_000_000_000...99_999_999_999_999_999_999_999_999_999 => 29,
        100_000_000_000_000_000_000_000_000_000...999_999_999_999_999_999_999_999_999_999 => 30,

        1_000_000_000_000_000_000_000_000_000_000...9_999_999_999_999_999_999_999_999_999_999 => 31,
        10_000_000_000_000_000_000_000_000_000_000...99_999_999_999_999_999_999_999_999_999_999 => 32,
        100_000_000_000_000_000_000_000_000_000_000...999_999_999_999_999_999_999_999_999_999_999 => 33,

        1_000_000_000_000_000_000_000_000_000_000_000...9_999_999_999_999_999_999_999_999_999_999_999 => 34,
        10_000_000_000_000_000_000_000_000_000_000_000...99_999_999_999_999_999_999_999_999_999_999_999 => 35,
        100_000_000_000_000_000_000_000_000_000_000_000...999_999_999_999_999_999_999_999_999_999_999_999 => 36,

        1_000_000_000_000_000_000_000_000_000_000_000_000...9_999_999_999_999_999_999_999_999_999_999_999_999 => 37,
        10_000_000_000_000_000_000_000_000_000_000_000_000...99_999_999_999_999_999_999_999_999_999_999_999_999 => 38,
        100_000_000_000_000_000_000_000_000_000_000_000_000...340_282_366_920_938_463_463_374_607_431_768_211_455 => 39,
    };
}

//+============================================================================================
//+ Tests: u0, u1, u2, u8, u16, u32, u64, u128, u129, u130
//+============================================================================================

test "countDigitSwitcher() - Unsigned Integer Types" {
    const expect = std.testing.expectEqual;
    const result = countDigitSwitcher;

    const minInteger = std.math.minInt;
    const maxInteger = std.math.maxInt;

    {
        const typ = u0;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 1;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(u256, max_num)));
    }

    {
        const typ = u1;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 1;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(u256, max_num)));
    }

    {
        const typ = u2;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 1;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(u256, max_num)));
    }

    {
        const typ = u8;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 3;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(u256, max_num)));
    }

    {
        const typ = u16;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 5;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(u256, max_num)));
    }

    {
        const typ = u32;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 10;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(u256, max_num)));
    }

    {
        const typ = u64;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 20;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(u256, max_num)));
    }

    {
        const typ = u128;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 39;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(u256, max_num)));
    }

    {
        const typ = u129;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        //# errors occur
        // const max_num = maxInteger(typ);
        // const max_res = 39;

        // try expect(max_res, result(max_num));
        // try expect(max_res, result(@as(typ, max_num)));
        // try expect(max_res, result(@as(u256, max_num)));
    }

    {
        const typ = u130;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(u256, min_num)));

        //# errors occur
        // const max_num = maxInteger(typ);
        // const max_res = 39;

        // try expect(max_res, result(max_num));
        // try expect(max_res, result(@as(typ, max_num)));
        // try expect(max_res, result(@as(u256, max_num)));
    }
}

//+============================================================================================
//+ Tests: i0, i1, i2, i8, i16, i32, i64, i128, i129, i130
//+============================================================================================

test "countDigitSwitcher() - Signed Integer Types" {
    const expect = std.testing.expectEqual;
    const result = countDigitSwitcher;

    const minInteger = std.math.minInt;
    const maxInteger = std.math.maxInt;

    {
        const typ = i0;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(i256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 1;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(i256, max_num)));
    }

    {
        const typ = i1;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(i256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 1;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(i256, max_num)));
    }

    {
        const typ = i2;

        const min_num = minInteger(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(i256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 1;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(i256, max_num)));
    }

    {
        const typ = i8;

        const min_num = minInteger(typ);
        const min_res = 3;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(i256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 3;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(i256, max_num)));
    }

    {
        const typ = i16;

        const min_num = minInteger(typ);
        const min_res = 5;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(i256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 5;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(i256, max_num)));
    }

    {
        const typ = i32;

        const min_num = minInteger(typ);
        const min_res = 10;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(i256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 10;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(i256, max_num)));
    }

    {
        const typ = i64;

        const min_num = minInteger(typ);
        const min_res = 19;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(i256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 19;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(i256, max_num)));
    }

    {
        const typ = i128;

        const min_num = minInteger(typ);
        const min_res = 39;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(i256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 39;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(i256, max_num)));
    }

    {
        const typ = i129;

        const min_num = minInteger(typ);
        const min_res = 39;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(typ, min_num)));
        try expect(min_res, result(@as(i256, min_num)));

        const max_num = maxInteger(typ);
        const max_res = 39;

        try expect(max_res, result(max_num));
        try expect(max_res, result(@as(typ, max_num)));
        try expect(max_res, result(@as(i256, max_num)));
    }

    {
        //# errors occur
        // const typ = i130;

        // const min_num = minInteger(typ);
        // const min_res = 39;

        // try expect(min_res, result(min_num));
        // try expect(min_res, result(@as(typ, min_num)));
        // try expect(min_res, result(@as(i256, min_num)));

        // const max_num = maxInteger(typ);
        // const max_res = 39;

        // try expect(max_res, result(max_num));
        // try expect(max_res, result(@as(typ, max_num)));
        // try expect(max_res, result(@as(i256, max_num)));
    }
}

//+============================================================================================
//+ Tests: f16, f32, f64, f80, f128
//+============================================================================================

test "countDigitSwitcher() - Float Types" {
    const expect = std.testing.expectEqual;
    const result = countDigitSwitcher;

    const minFloat = std.math.floatMin;
    const maxFloat = std.math.floatMax;

    {
        const typ = f16;

        const min_num = minFloat(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(comptime_float, min_num)));

        try expect(min_res, result(-min_num));
        try expect(min_res, result(@as(comptime_float, -min_num)));

        const max_num = maxFloat(typ);
        const max_res = 5;

        //# errors occur
        // try expect(max_res, result(max_num));
        try expect(max_res, result(@as(comptime_float, max_num)));

        //# errors occur
        // try expect(max_res, result(-max_num));
        try expect(max_res, result(@as(comptime_float, -max_num)));

        //+ first number whose integer part cannot be exactly represented by type f16 it is
        //+ 2049, as 2048
        const f16_man = @as(u128, @intCast(std.math.floatMantissaBits(typ)));
        const f16_max = comptime std.math.pow(u128, 2, f16_man + 1) + 1;
        const f16_res = 4;

        const f16_prior = @as(comptime_float, @floatFromInt(f16_max - 1));

        try expect(f16_res, result(f16_prior));
        try expect(f16_res, result(@as(typ, f16_prior)));

        try expect(f16_res, result(-f16_prior));
        try expect(f16_res, result(@as(typ, -f16_prior)));

        const f16_first = @as(comptime_float, @floatFromInt(f16_max));

        try expect(f16_res, result(f16_first));
        try expect(f16_res, result(@as(typ, f16_first)));

        try expect(f16_res, result(-f16_first));
        try expect(f16_res, result(@as(typ, -f16_first)));

        const f16_after = @as(comptime_float, @floatFromInt(f16_max + 1));

        try expect(f16_res, result(f16_after));
        //# errors occur
        // try expect(f16_res, result(@as(typ, f16_after)));

        try expect(f16_res, result(-f16_after));
        //# errors occur
        // try expect(f16_res, result(@as(typ, -f16_after)));
    }

    {
        const typ = f32;

        const min_num = minFloat(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(comptime_float, min_num)));

        try expect(min_res, result(-min_num));
        try expect(min_res, result(@as(comptime_float, -min_num)));

        //# errors occur
        // const max_num = maxFloat(typ);
        // const max_res = 39;

        // try expect(max_res, result(max_num));
        // try expect(max_res, result(@as(comptime_float, max_num)));

        // try expect(max_res, result(-max_num));
        // try expect(max_res, result(@as(comptime_float, -max_num)));

        //+ first number whose integer part cannot be exactly represented by type f32 it is
        //+ 16777217, as 16777216
        const f32_man = @as(u128, @intCast(std.math.floatMantissaBits(typ)));
        const f32_max = comptime std.math.pow(u128, 2, f32_man + 1) + 1;
        const f32_res = 8;

        const f32_prior = @as(comptime_float, @floatFromInt(f32_max - 1));

        try expect(f32_res, result(f32_prior));
        try expect(f32_res, result(@as(typ, f32_prior)));

        try expect(f32_res, result(-f32_prior));
        try expect(f32_res, result(@as(typ, -f32_prior)));

        const f32_first = @as(comptime_float, @floatFromInt(f32_max));

        try expect(f32_res, result(f32_first));
        try expect(f32_res, result(@as(typ, f32_first)));

        try expect(f32_res, result(-f32_first));
        try expect(f32_res, result(@as(typ, -f32_first)));

        const f32_after = @as(comptime_float, @floatFromInt(f32_max + 1));

        try expect(f32_res, result(f32_after));
        //# errors occur
        // try expect(f32_res, result(@as(typ, f32_after)));

        try expect(f32_res, result(-f32_after));
        //# errors occur
        // try expect(f32_res, result(@as(typ, -f32_after)));
    }

    {
        const typ = f64;

        const min_num = minFloat(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(comptime_float, min_num)));

        try expect(min_res, result(-min_num));
        try expect(min_res, result(@as(comptime_float, -min_num)));

        //# errors occur
        // const max_num = maxFloat(typ);
        // const max_res = 309;

        // try expect(max_res, result(max_num));
        // try expect(max_res, result(@as(comptime_float, max_num)));

        // try expect(max_res, result(-max_num));
        // try expect(max_res, result(@as(comptime_float, -max_num)));

        //+ first number whose integer part cannot be exactly represented by type f64 it is
        //+ 9007199254740993, as 9007199254740992
        const f64_man = @as(u128, @intCast(std.math.floatMantissaBits(typ)));
        const f64_max = comptime std.math.pow(u128, 2, f64_man + 1) + 1;
        const f64_res = 16;

        const f64_prior = @as(comptime_float, @floatFromInt(f64_max - 1));

        try expect(f64_res, result(f64_prior));
        try expect(f64_res, result(@as(typ, f64_prior)));

        try expect(f64_res, result(-f64_prior));
        try expect(f64_res, result(@as(typ, -f64_prior)));

        const f64_first = @as(comptime_float, @floatFromInt(f64_max));

        try expect(f64_res, result(f64_first));
        try expect(f64_res, result(@as(typ, f64_first)));

        try expect(f64_res, result(-f64_first));
        try expect(f64_res, result(@as(typ, -f64_first)));

        const f64_after = @as(comptime_float, @floatFromInt(f64_max + 1));

        try expect(f64_res, result(f64_after));
        //# errors occur
        // try expect(f64_res, result(@as(typ, f64_after)));

        try expect(f64_res, result(-f64_after));
        //# errors occur
        // try expect(f64_res, result(@as(typ, -f64_after)));
    }

    {
        const typ = f80;

        const min_num = minFloat(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(comptime_float, min_num)));

        try expect(min_res, result(-min_num));
        try expect(min_res, result(@as(comptime_float, -min_num)));

        //# errors occur
        // const max_num = maxFloat(typ);
        // const max_res = 4933;

        // try expect(max_res, result(max_num));
        // try expect(max_res, result(@as(comptime_float, max_num)));

        // try expect(max_res, result(-max_num));
        // try expect(max_res, result(@as(comptime_float, -max_num)));

        //+ first number whose integer part cannot be exactly represented by type f80 it is
        //+ 36893488147419103233, as 36893488147419103232
        //^ for type f80, 36893488147419103234 is also represented as 36893488147419103232
        //^ and passes the tests, so the first number used will be 36893488147419103234
        const f80_man = @as(u128, @intCast(std.math.floatMantissaBits(typ)));
        const f80_max = comptime std.math.pow(u128, 2, f80_man + 1) + 2;
        const f80_res = 20;

        const f80_prior = @as(comptime_float, @floatFromInt(f80_max - 1));

        try expect(f80_res, result(f80_prior));
        try expect(f80_res, result(@as(typ, f80_prior)));

        try expect(f80_res, result(-f80_prior));
        try expect(f80_res, result(@as(typ, -f80_prior)));

        const f80_first = @as(comptime_float, @floatFromInt(f80_max));

        try expect(f80_res, result(f80_first));
        try expect(f80_res, result(@as(typ, f80_first)));

        try expect(f80_res, result(-f80_first));
        try expect(f80_res, result(@as(typ, -f80_first)));

        const f80_after = @as(comptime_float, @floatFromInt(f80_max + 1));

        try expect(f80_res, result(f80_after));
        //# errors occur
        // try expect(f80_res, result(@as(typ, f80_after)));

        try expect(f80_res, result(-f80_after));
        //# errors occur
        // try expect(f80_res, result(@as(typ, -f80_after)));
    }

    {
        const typ = f128;

        const min_num = minFloat(typ);
        const min_res = 1;

        try expect(min_res, result(min_num));
        try expect(min_res, result(@as(comptime_float, min_num)));

        try expect(min_res, result(-min_num));
        try expect(min_res, result(@as(comptime_float, -min_num)));

        //# errors occur
        // const max_num = maxFloat(typ);
        // const max_res = 4933;

        // try expect(max_res, result(max_num));
        // try expect(max_res, result(@as(comptime_float, max_num)));

        // try expect(max_res, result(-max_num));
        // try expect(max_res, result(@as(comptime_float, -max_num)));

        //+ first number whose integer part cannot be exactly represented by type f128 it is
        //+ 10384593717069655257060992658440193, as 10384593717069655257060992658440192
        const f128_man = @as(u128, @intCast(std.math.floatMantissaBits(typ)));
        const f128_max = comptime std.math.pow(u128, 2, f128_man + 1) + 1;
        const f128_res = 35;

        const f128_prior = @as(comptime_float, @floatFromInt(f128_max - 1));

        try expect(f128_res, result(f128_prior));
        try expect(f128_res, result(@as(typ, f128_prior)));

        try expect(f128_res, result(-f128_prior));
        try expect(f128_res, result(@as(typ, -f128_prior)));

        const f128_first = @as(comptime_float, @floatFromInt(f128_max));

        try expect(f128_res, result(f128_first));
        try expect(f128_res, result(@as(typ, f128_first)));

        try expect(f128_res, result(-f128_first));
        try expect(f128_res, result(@as(typ, -f128_first)));

        //# errors occur
        // const f128_after = @as(comptime_float, @floatFromInt(f128_max + 1));

        // try expect(f128_res, result(f128_after));
        // try expect(f128_res, result(@as(typ, f128_after)));

        // try expect(f128_res, result(-f128_after));
        // try expect(f128_res, result(@as(typ, -f128_after)));
    }
}

//+============================================================================================
//+ Tests: first numbers more accurate
//+============================================================================================

test "countDigitSwitcher() - First Number Accurate" {
    const expect = std.testing.expectEqual;
    const result = countDigitSwitcher;

    {
        const nums = .{
            10384593717069655257060992658440192.0,
            10384593717069655257060992658440192.1,
            10384593717069655257060992658440192.2,
            10384593717069655257060992658440192.3,
            10384593717069655257060992658440192.4,
            10384593717069655257060992658440192.5,
            10384593717069655257060992658440192.6,
            10384593717069655257060992658440192.7,
            10384593717069655257060992658440192.8,
            10384593717069655257060992658440192.9,
            10384593717069655257060992658440193.0,

            //# errors occur
            // 10384593717069655257060992658440193.1,
            // 10384593717069655257060992658440193.2,
            // 10384593717069655257060992658440193.3,
            // 10384593717069655257060992658440193.4,
            // 10384593717069655257060992658440193.5,
            // 10384593717069655257060992658440193.6,
            // 10384593717069655257060992658440193.7,
            // 10384593717069655257060992658440193.8,
            // 10384593717069655257060992658440193.9,
            // 10384593717069655257060992658440194.0,
        };

        inline for (nums) |num| {
            try expect(35, result(num));
            try expect(35, result(-num));
        }
    }

    {
        const nums = [_]f16{
            2048.0,
            2048.1,
            2048.2,
            2048.3,
            2048.4,
            2048.5,
            2048.6,
            2048.7,
            2048.8,
            2048.9,
            2049.0,
            2049.0000000000000000000000000000001,

            //# errors occur
            // 2049.000000000000000000000000000001,
            // 2049.1,
            // 2049.2,
            // 2049.3,
            // 2049.4,
            // 2049.5,
            // 2049.6,
            // 2049.7,
            // 2049.8,
            // 2049.9,
            // 2050.0,
        };

        inline for (nums) |num| {
            try expect(4, result(num));
            try expect(4, result(-num));
        }
    }

    {
        const nums = [_]f32{
            16777216.0,
            16777216.1,
            16777216.2,
            16777216.3,
            16777216.4,
            16777216.5,
            16777216.6,
            16777216.7,
            16777216.8,
            16777216.9,
            16777217.0,
            16777217.000000000000000000000000001,

            //# errors occur
            // 16777217.00000000000000000000000001,
            // 16777217.1,
            // 16777217.2,
            // 16777217.3,
            // 16777217.4,
            // 16777217.5,
            // 16777217.6,
            // 16777217.7,
            // 16777217.8,
            // 16777217.9,
            // 16777218.0,
        };

        inline for (nums) |num| {
            try expect(8, result(num));
            try expect(8, result(-num));
        }
    }

    {
        const nums = [_]f64{
            9007199254740992.0,
            9007199254740992.1,
            9007199254740992.2,
            9007199254740992.3,
            9007199254740992.4,
            9007199254740992.5,
            9007199254740992.6,
            9007199254740992.7,
            9007199254740992.8,
            9007199254740992.9,
            9007199254740993.0,
            9007199254740993.0000000000000000001,

            //# errors occur
            // 9007199254740993.000000000000000001,
            // 9007199254740993.1,
            // 9007199254740993.2,
            // 9007199254740993.3,
            // 9007199254740993.4,
            // 9007199254740993.5,
            // 9007199254740993.6,
            // 9007199254740993.7,
            // 9007199254740993.8,
            // 9007199254740993.9,
            // 9007199254740994.0,
        };

        inline for (nums) |num| {
            try expect(16, result(num));
            try expect(16, result(-num));
        }
    }

    {
        const nums = [_]f80{
            36893488147419103232.0,
            36893488147419103232.1,
            36893488147419103232.2,
            36893488147419103232.3,
            36893488147419103232.4,
            36893488147419103232.5,
            36893488147419103232.6,
            36893488147419103232.7,
            36893488147419103232.8,
            36893488147419103232.9,
            36893488147419103233.0,

            //^ actually the first number is 36893488147419103233 but it is used
            //^ 36893488147419103234 because it passes the tests
            36893488147419103233.1,
            36893488147419103233.2,
            36893488147419103233.3,
            36893488147419103233.4,
            36893488147419103233.5,
            36893488147419103233.6,
            36893488147419103233.7,
            36893488147419103233.8,
            36893488147419103233.9,
            36893488147419103234.0,
            36893488147419103234.000000000000001,

            //# errors occur
            // 36893488147419103234.00000000000001,
            // 36893488147419103234.1,
            // 36893488147419103234.2,
            // 36893488147419103234.3,
            // 36893488147419103234.4,
            // 36893488147419103234.5,
            // 36893488147419103234.6,
            // 36893488147419103234.7,
            // 36893488147419103234.8,
            // 36893488147419103234.9,
            // 36893488147419103235.0,
        };

        inline for (nums) |num| {
            try expect(20, result(num));
            try expect(20, result(-num));
        }
    }

    {
        const nums = [_]f128{
            10384593717069655257060992658440192.0,
            10384593717069655257060992658440192.1,
            10384593717069655257060992658440192.2,
            10384593717069655257060992658440192.3,
            10384593717069655257060992658440192.4,
            10384593717069655257060992658440192.5,
            10384593717069655257060992658440192.6,
            10384593717069655257060992658440192.7,
            10384593717069655257060992658440192.8,
            10384593717069655257060992658440192.9,
            10384593717069655257060992658440193.0,

            //# errors occur
            // 10384593717069655257060992658440193.1,
            // 10384593717069655257060992658440193.2,
            // 10384593717069655257060992658440193.3,
            // 10384593717069655257060992658440193.4,
            // 10384593717069655257060992658440193.5,
            // 10384593717069655257060992658440193.6,
            // 10384593717069655257060992658440193.7,
            // 10384593717069655257060992658440193.8,
            // 10384593717069655257060992658440193.9,
            // 10384593717069655257060992658440194.0,
        };

        inline for (nums) |num| {
            try expect(35, result(num));
            try expect(35, result(-num));
        }
    }
}

//+============================================================================================
//+ Tests: invalid types
//+============================================================================================

// test "countDigitSwitcher() - Error Types" {
//     const expect = std.testing.expectEqual;
//     const result = countDigitSwitcher;

//     //# errors occur
//     try expect(4, result("2050"));
//     try expect(4, result(@as([]const u8, "-2050")));
//     try expect(0, result(.{}));
//     try expect(1, result(.{0}));
//     try expect(1, result(.{0.0}));
//     try expect(2, result(.{'a'}));
//     try expect(0, result(true));
//     try expect(0, result(null));
//     try expect(0, result(void));
//     try expect(0, result(undefined));
// }
