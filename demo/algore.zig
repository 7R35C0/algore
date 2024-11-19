//:========================================================================
//: Licensed under the [MIT License](LICENSE).
//:
//: Tested with zig version 0.13.0 on Linux Fedora 39.
//:========================================================================

const std = @import("std");
const assert = std.debug.assert;

//+ Each module can be used indirectly or directly.
//+ More examples of direct use are in the other demos.

pub fn main() !void {

    //+ Indirect use case.
    {
        const result_long = @import("algore").digit.countIterative;

        assert(result_long(0) == 1);
        assert(result_long(0.0) == 1);

        assert(result_long(std.math.maxInt(u129)) == null);
        assert(result_long(@as(u129, std.math.maxInt(u129))) == null);
    }

    //+ Direct use case, slightly shorter and more explicit.
    {
        const result_short = @import("digit").countIterative;

        assert(result_short(0) == 1);
        assert(result_short(0.0) == 1);

        assert(result_short(std.math.maxInt(u129)) == null);
        assert(result_short(@as(u129, std.math.maxInt(u129))) == null);
    }
}
