const std = @import("std");

const assert = std.debug.assert;

const countDigitIterative = @import("algore").countDigitIterative;
const countDigitLogarithmic = @import("algore").countDigitLogarithmic;
const countDigitLookup = @import("algore").countDigitLookup;
const countDigitRecursive = @import("algore").countDigitRecursive;
const countDigitStringify = @import("algore").countDigitStringify;
const countDigitSwitcher = @import("algore").countDigitSwitcher;
const NearestIntegerType = @import("algore").NearestIntegerType;

pub fn main() !void {
    assert(countDigitIterative(0) == 1);
    assert(countDigitIterative(0.0) == 1);

    assert(countDigitLogarithmic(0) == 1);
    assert(countDigitLogarithmic(0.0) == 1);

    assert(countDigitLookup(0) == 1);
    assert(countDigitLookup(0.0) == 1);

    assert(countDigitRecursive(0) == 1);
    assert(countDigitRecursive(0.0) == 1);

    assert(countDigitStringify(0) == 1);
    assert(countDigitStringify(0.0) == 1);

    assert(countDigitSwitcher(0) == 1);
    assert(countDigitSwitcher(0.0) == 1);

    assert(NearestIntegerType(-1) == i1);
    assert(NearestIntegerType(0) == u0);
    assert(NearestIntegerType(1) == u1);
}
