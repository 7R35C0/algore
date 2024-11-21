//:========================================================================
//: Licensed under the [MIT License](LICENSE).
//:
//: Tested with zig version 0.13.0 on Linux Fedora 39.
//:========================================================================

const std = @import("std");
const assert = std.debug.assert;

const result = @import("algore").digit.countIterative;
// const result = @import("algore").digit.countLogarithmic;
// const result = @import("algore").digit.countLookup;
// const result = @import("algore").digit.countRecursive;
// const result = @import("algore").digit.countStringify;
// const result = @import("algore").digit.countSwitcher;

pub fn main() !void {
    //^--------------------------------------------------------------
    //^ Supported types
    //^--------------------------------------------------------------

    assert(result(0) == 1);
    assert(result(0.0) == 1);

    assert(result(@as(u32, 0)) == 1);
    assert(result(@as(f32, 0.0)) == 1);

    assert(result(1_000_000) == 7);
    assert(result(-1_000_000) == 7);

    assert(result(1_000_000.0) == 7);
    assert(result(-1_000_000.0) == 7);

    assert(result(@as(u256, 1_000_000)) == 7);
    assert(result(@as(i256, -1_000_000)) == 7);

    assert(result(@as(i32, 1_000_000)) == 7);
    assert(result(@as(i32, -1_000_000)) == 7);

    assert(result(@as(f32, 1_000_000.0)) == 7);
    assert(result(@as(f32, -1_000_000.0)) == 7);

    assert(result(@as(f16, 1_000.0)) == 4);
    assert(result(@as(f16, -1_000.0)) == 4);

    // decimal: 97, 101
    assert(result('a') == 2);
    assert(result('e') == 3);

    // decimal: 9889, 128175
    assert(result('⚡') == 4);
    assert(result('💯') == 6);

    // decimal: 16, 75
    assert(result('\x10') == 2);
    assert(result('\x4B') == 2);

    // decimal: 1000, 1114111
    assert(result('\u{3E8}') == 4);
    assert(result('\u{10FFFF}') == 7);

    //^--------------------------------------------------------------
    //^ Unsupported types, returns `null`
    //^--------------------------------------------------------------

    assert(result(std.math.maxInt(u129)) == null);
    assert(result(@as(u129, std.math.maxInt(u129))) == null);
    assert(result(std.math.minInt(i130)) == null);
    assert(result(@as(i130, std.math.minInt(i130))) == null);
    assert(result(@as(f16, 2050)) == null);

    assert(result("2050") == null);
    assert(result(@as([]const u8, "-2050")) == null);
    assert(result(.{}) == null);
    assert(result(.{0}) == null);
    assert(result(.{0.0}) == null);
    assert(result(.{'a'}) == null);
    assert(result(true) == null);
    assert(result(null) == null);
    assert(result(void) == null);
    assert(result(undefined) == null);
}
