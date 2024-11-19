//:========================================================================
//: Licensed under the [MIT License](LICENSE).
//:
//: Tested with zig version 0.13.0 on Linux Fedora 39.
//:========================================================================

//! Each module has its own repo, for standalone use case,
//! see the links below.
//!
//! * [digit](https://github.com/7R35C0/digit)
//!     -- counting digits with various algorithms
//! * [singly_linked_list](https://github.com/7R35C0/singly_linked_list)
//!     -- common functions for singly linked lists

const std = @import("std");

pub const digit = @import("digit");
pub const singly_linked_list = @import("singly_linked_list");

//+========================================================================
//+ Tests
//+========================================================================

//^--------------------------------------------------------------
//^ Above imports
//^--------------------------------------------------------------

//+ Test all above imports.
test "algore" {
    std.testing.refAllDecls(@This());
}
