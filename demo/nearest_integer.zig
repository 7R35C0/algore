const std = @import("std");

const assert = std.debug.assert;
const result = @import("algore").NearestIntegerType;

pub fn main() !void {
    assert(result(-5) == i4);
    assert(result(-4) == i3);
    assert(result(-3) == i3);
    assert(result(-2) == i2);
    assert(result(-1) == i1);
    assert(result(0) == u0);
    assert(result(1) == u1);
    assert(result(2) == u2);
    assert(result(3) == u2);
    assert(result(4) == u3);
    assert(result(5) == u3);

    assert(result(@as(i15, 0)) == i0);
    assert(result(@as(u45, 0)) == u0);

    assert(result(-340282366920938463463374607431768211456) == i129);
    assert(result(-340282366920938463463374607431768211455) == i129);

    assert(result(-170141183460469231731687303715884105729) == i129);
    assert(result(-170141183460469231731687303715884105728) == i128);
    assert(result(-170141183460469231731687303715884105727) == i128);

    assert(result(-9223372036854775809) == i65);
    assert(result(-9223372036854775808) == i64);
    assert(result(-9223372036854775807) == i64);

    assert(result(18446744073709551614) == u64);
    assert(result(18446744073709551615) == u64);
    assert(result(18446744073709551616) == u65);

    assert(result(340282366920938463463374607431768211454) == u128);
    assert(result(340282366920938463463374607431768211455) == u128);

    // decimal: 97, 101
    assert(result('a') == u7);
    assert(result('e') == u7);

    // decimal: 9889, 128175
    assert(result('⚡') == u14);
    assert(result('💯') == u17);

    // decimal: 16, 75
    assert(result('\x10') == u5);
    assert(result('\x4B') == u7);

    // decimal: 1000, 1114111
    assert(result('\u{3E8}') == u10);
    assert(result('\u{10FFFF}') == u21);

    //# errors occur
    // assert(result(0.0) == null);
    // assert(result(@as(f16, 0.0)) == null);
    // assert(result(std.math.floatMin(f32)) == null);
    // assert(result(std.math.floatMax(f64)) == null);
    // assert(result(@as(f128, 0)) == null);

    // assert(result("2050") == null);
    // assert(result(@as([]const u8, "-2050")) == null);
    // assert(result(.{}) == null);
    // assert(result(.{0}) == null);
    // assert(result(.{0.0}) == null);
    // assert(result(.{'a'}) == null);
    // assert(result(true) == null);
    // assert(result(null) == null);
    // assert(result(void) == null);
    // assert(result(undefined) == null);
}
