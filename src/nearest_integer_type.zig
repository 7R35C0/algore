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

// maximum bit size supported, restricts the values ​​for a `number` as follows:
// * for negatives - to minimum value of signed integer type with bit width `bit_size + 1`
// * for positives - to maximum value of unsigned integer type with bit width `bit_size`
//
// this restriction leads to a nearly symmetric range of numbers
// eg. bit_size =  128
//     min_num  = -340282366920938463463374607431768211456 as minimum i129
//     max_num  =  340282366920938463463374607431768211455 as maximum u128
const bit_size: u16 = 128;

/// Returns the nearest integer type that can represent exactly integer `number`.
///
/// Supported number types and ranges:
/// * .ComptimeInt, .Int: ∓340282366920938463463374607431768211455
///   * min(i129) = -340282366920938463463374607431768211456 it is accepted to cover the type
///
/// Note that the resulting types for a `number` are:
/// * .ComptimeInt:
///   * negative: `i1...i129`
///   * zero:     `u0`
///   * positive: `u1...u128`
/// * .Int:
///   * signed:   signed type, usually with fewer bits
///   * unsigned: unsigned type, usually with fewer bits
pub fn NearestIntegerType(number: anytype) type {
    const bits = checkError(number);

    return DispatchIntegerTypes(bits, number);
}

// check `number` types and ranges, return bit size of `number` or errors occur
fn checkError(number: anytype) u16 {
    return switch (@typeInfo(@TypeOf(number))) {
        .ComptimeInt, .Int => blk: {
            const min_num = std.math.minInt(
                std.meta.Int(.signed, bit_size + 1),
            );
            if (number < min_num) {
                @compileError(
                    "unsupported number `" ++ std.fmt.comptimePrint("{}", .{number}) ++ "` for type `" ++ @typeName(@TypeOf(number)) ++ "` - NearestIntegerType() is not implemented for a number < " ++ std.fmt.comptimePrint("{}", .{min_num}) ++ " for this type",
                );
            }

            const max_num = std.math.maxInt(
                std.meta.Int(.unsigned, bit_size),
            );
            if (number > max_num) {
                @compileError(
                    "unsupported number `" ++ std.fmt.comptimePrint("{}", .{number}) ++ "` for type `" ++ @typeName(@TypeOf(number)) ++ "` - NearestIntegerType() is not implemented for a number > " ++ std.fmt.comptimePrint("{}", .{max_num}) ++ " for this type",
                );
            }

            if (@sizeOf(@TypeOf(number)) == 0)
                break :blk if (number < 0) bit_size + 1 else bit_size;

            break :blk @typeInfo(@TypeOf(number)).Int.bits;
        },

        else => {
            @compileError("unsupported type `" ++ @typeName(@TypeOf(number)) ++ "` - NearestIntegerType() is not implemented for this type");
        },
    };
}

// handler for integer types
fn DispatchIntegerTypes(bits: u16, number: anytype) type {
    return switch (@typeInfo(@TypeOf(number))) {
        .ComptimeInt => blk: {
            if (number < 0) break :blk NearestSignedType(bits, number);
            if (number > 0) break :blk NearestUnsignedType(bits, number);

            break :blk u0;
        },

        .Int => switch (@typeInfo(@TypeOf(number)).Int.signedness) {
            .signed => blk: {
                if (number != 0) break :blk NearestSignedType(bits, number);

                break :blk i0;
            },
            .unsigned => blk: {
                if (number != 0) break :blk NearestUnsignedType(bits, number);

                break :blk u0;
            },
        },

        else => unreachable,
    };
}

// the algorithm for signed integer types
fn NearestSignedType(bits: u16, number: anytype) type {
    var bit_head: u16 = 0;
    var bit_tail: u16 = bits;
    var num_type: type = undefined;

    while (bit_head <= bit_tail) {
        const bit_midl = @divFloor(bit_head + bit_tail, 2);
        const chk_type = std.meta.Int(
            .signed,
            @as(u16, @intCast(bit_midl)),
        );

        if (number == @as(chk_type, @truncate(number))) {
            num_type = chk_type;
            bit_tail = bit_midl - 1;
        } else {
            bit_head = bit_midl + 1;
        }
    }

    return num_type;
}

// the algorithm for unsigned integer types
fn NearestUnsignedType(bits: u16, number: anytype) type {
    var bit_head: u16 = 0;
    var bit_tail: u16 = bits;
    var num_type: type = undefined;

    while (bit_head <= bit_tail) {
        const bit_midl = @divFloor(bit_head + bit_tail, 2);
        const chk_type = std.meta.Int(
            .unsigned,
            @as(u16, @intCast(bit_midl)),
        );

        if (number == @as(chk_type, @truncate(number))) {
            num_type = chk_type;
            bit_tail = bit_midl - 1;
        } else {
            bit_head = bit_midl + 1;
        }
    }

    return num_type;
}

//+============================================================================================
//+ Tests: u0, u1, u2, u8, u16, u32, u64, u128, u129, u130
//+============================================================================================

test "NearestIntegerType() - Unsigned Integer Types" {
    @setEvalBranchQuota(2000);

    const expect = std.testing.expectEqual;
    const result = NearestIntegerType;

    const minInteger = std.math.minInt;
    const maxInteger = std.math.maxInt;

    {
        const typ = u0;

        const min_num = minInteger(typ);
        try expect(typ, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        try expect(typ, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(u256, max_num)));
    }

    {
        const typ = u1;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(u0, result(@as(typ, min_num)));
        try expect(u0, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        try expect(typ, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(u256, max_num)));
    }

    {
        const typ = u2;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(u0, result(@as(typ, min_num)));
        try expect(u0, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        try expect(typ, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(u256, max_num)));
    }

    {
        const typ = u8;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(u0, result(@as(typ, min_num)));
        try expect(u0, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        try expect(typ, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(u256, max_num)));
    }

    {
        const typ = u16;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(u0, result(@as(typ, min_num)));
        try expect(u0, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        try expect(typ, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(u256, max_num)));
    }

    {
        const typ = u32;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(u0, result(@as(typ, min_num)));
        try expect(u0, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        try expect(typ, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(u256, max_num)));
    }

    {
        const typ = u64;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(u0, result(@as(typ, min_num)));
        try expect(u0, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        try expect(typ, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(u256, max_num)));
    }

    {
        const typ = u128;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(u0, result(@as(typ, min_num)));
        try expect(u0, result(@as(u256, min_num)));

        const max_num = maxInteger(typ);
        try expect(typ, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(u256, max_num)));
    }

    {
        const typ = u129;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(u0, result(@as(typ, min_num)));
        try expect(u0, result(@as(u256, min_num)));

        //# errors occur
        // const max_num = maxInteger(typ);
        // try expect(typ, result(max_num));
        // try expect(typ, result(@as(typ, max_num)));
        // try expect(typ, result(@as(u256, max_num)));
    }

    {
        const typ = u130;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(u0, result(@as(typ, min_num)));
        try expect(u0, result(@as(u256, min_num)));

        //# errors occur
        // const max_num = maxInteger(typ);
        // try expect(typ, result(max_num));
        // try expect(typ, result(@as(typ, max_num)));
        // try expect(typ, result(@as(u256, max_num)));
    }
}

//+============================================================================================
//+ Tests: i0, i1, i2, i8, i16, i32, i64, i128, i129, i130
//+============================================================================================

test "NearestIntegerType() - Signed Integer Types" {
    @setEvalBranchQuota(2000);

    const expect = std.testing.expectEqual;
    const result = NearestIntegerType;

    const minInteger = std.math.minInt;
    const maxInteger = std.math.maxInt;

    {
        const typ = i0;

        const min_num = minInteger(typ);
        try expect(u0, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(i257, min_num)));

        const max_num = maxInteger(typ);
        try expect(u0, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(i257, max_num)));
    }

    {
        const typ = i1;

        const min_num = minInteger(typ);
        try expect(typ, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(i257, min_num)));

        const max_num = maxInteger(typ);
        try expect(u0, result(max_num));
        try expect(i0, result(@as(typ, max_num)));
        try expect(i0, result(@as(i257, max_num)));
    }

    {
        const typ = i2;

        const min_num = minInteger(typ);
        try expect(typ, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(i257, min_num)));

        const max_num = maxInteger(typ);
        try expect(u1, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(i257, max_num)));
    }

    {
        const typ = i8;

        const min_num = minInteger(typ);
        try expect(typ, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(i257, min_num)));

        const max_num = maxInteger(typ);
        try expect(u7, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(i257, max_num)));
    }

    {
        const typ = i16;

        const min_num = minInteger(typ);
        try expect(typ, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(i257, min_num)));

        const max_num = maxInteger(typ);
        try expect(u15, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(i257, max_num)));
    }

    {
        const typ = i32;

        const min_num = minInteger(typ);
        try expect(typ, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(i257, min_num)));

        const max_num = maxInteger(typ);
        try expect(u31, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(i257, max_num)));
    }

    {
        const typ = i64;

        const min_num = minInteger(typ);
        try expect(typ, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(i257, min_num)));

        const max_num = maxInteger(typ);
        try expect(u63, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(i257, max_num)));
    }

    {
        const typ = i128;

        const min_num = minInteger(typ);
        try expect(typ, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(i257, min_num)));

        const max_num = maxInteger(typ);
        try expect(u127, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(i257, max_num)));
    }

    {
        const typ = i129;

        const min_num = minInteger(typ);
        try expect(typ, result(min_num));
        try expect(typ, result(@as(typ, min_num)));
        try expect(typ, result(@as(i257, min_num)));

        const max_num = maxInteger(typ);
        try expect(u128, result(max_num));
        try expect(typ, result(@as(typ, max_num)));
        try expect(typ, result(@as(i257, max_num)));
    }

    {
        //# errors occur
        // const typ = i130;

        // const min_num = minInteger(typ);
        // try expect(typ, result(min_num));
        // try expect(typ, result(@as(typ, min_num)));
        // try expect(typ, result(@as(i257, min_num)));

        // const max_num = maxInteger(typ);
        // try expect(u129, result(max_num));
        // try expect(typ, result(@as(typ, max_num)));
        // try expect(typ, result(@as(i257, max_num)));
    }
}

//+============================================================================================
//+ Tests: invalid types
//+============================================================================================

// test "NearestIntegerType() - Error Types" {
//     const expect = std.testing.expectEqual;
//     const result = NearestIntegerType;

//     //# errors occur
//     try expect(null, result(0.0));
//     try expect(null, result(@as(f16, 0.0)));
//     try expect(null, result(std.math.floatMin(f32)));
//     try expect(null, result(std.math.floatMax(f64)));
//     try expect(null, result(@as(f128, 0)));

//     try expect(null, result("2050"));
//     try expect(null, result(@as([]const u8, "-2050")));
//     try expect(null, result(.{}));
//     try expect(null, result(.{0}));
//     try expect(null, result(.{0.0}));
//     try expect(null, result(.{'a'}));
//     try expect(null, result(true));
//     try expect(null, result(null));
//     try expect(null, result(void));
//     try expect(null, result(undefined));
// }
