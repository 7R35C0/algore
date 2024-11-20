//:========================================================================
//: Licensed under the [MIT License](LICENSE).
//:
//: Tested with zig version 0.13.0 on Linux Fedora 39.
//:========================================================================

const std = @import("std");
const assert = std.debug.assert;

const countDigit = @import("algore").digit.countIterative;
const SinglyLinkedList = @import("algore").singly_linked_list.SinglyLinkedList;

pub fn main() !void {

    //^--------------------------------------------------------------
    //^ Module `digit`
    //^--------------------------------------------------------------

    {
        //+ Supported types.
        {
            assert(countDigit(0) == 1);
            assert(countDigit(0.0) == 1);

            assert(countDigit(@as(u32, 0)) == 1);
            assert(countDigit(@as(f32, 0.0)) == 1);

            assert(countDigit(1_000_000) == 7);
            assert(countDigit(-1_000_000) == 7);

            assert(countDigit(1_000_000.0) == 7);
            assert(countDigit(-1_000_000.0) == 7);

            assert(countDigit(@as(u256, 1_000_000)) == 7);
            assert(countDigit(@as(i256, -1_000_000)) == 7);

            assert(countDigit(@as(i32, 1_000_000)) == 7);
            assert(countDigit(@as(i32, -1_000_000)) == 7);

            assert(countDigit(@as(f32, 1_000_000.0)) == 7);
            assert(countDigit(@as(f32, -1_000_000.0)) == 7);

            assert(countDigit(@as(f16, 1_000.0)) == 4);
            assert(countDigit(@as(f16, -1_000.0)) == 4);

            // decimal: 97, 101
            assert(countDigit('a') == 2);
            assert(countDigit('e') == 3);

            // decimal: 9889, 128175
            assert(countDigit('⚡') == 4);
            assert(countDigit('💯') == 6);

            // decimal: 16, 75
            assert(countDigit('\x10') == 2);
            assert(countDigit('\x4B') == 2);

            // decimal: 1000, 1114111
            assert(countDigit('\u{3E8}') == 4);
            assert(countDigit('\u{10FFFF}') == 7);
        }

        //+ Unsupported types, returns `null`.
        {
            assert(countDigit(std.math.maxInt(u129)) == null);
            assert(countDigit(@as(u129, std.math.maxInt(u129))) == null);
            assert(countDigit(std.math.minInt(i130)) == null);
            assert(countDigit(@as(i130, std.math.minInt(i130))) == null);
            assert(countDigit(@as(f16, 2050)) == null);

            assert(countDigit("2050") == null);
            assert(countDigit(@as([]const u8, "-2050")) == null);
            assert(countDigit(.{}) == null);
            assert(countDigit(.{0}) == null);
            assert(countDigit(.{0.0}) == null);
            assert(countDigit(.{'a'}) == null);
            assert(countDigit(true) == null);
            assert(countDigit(null) == null);
            assert(countDigit(void) == null);
            assert(countDigit(undefined) == null);
        }
    }

    //^--------------------------------------------------------------
    //^ Module `singly_linked_list`
    //^--------------------------------------------------------------

    {
        const Typ = usize;
        const Lst = SinglyLinkedList(Typ);
        const Nod = Lst.Node;

        var nod0 = Nod{ .data = 0, .next = null };
        var nod1 = Nod{ .data = 1, .next = null };
        var nod2 = Nod{ .data = 2, .next = null };
        var nod3 = Nod{ .data = 3, .next = null };
        var nod4 = Nod{ .data = 4, .next = null };

        var lst0 = Lst{};

        //+ Node `data` field type.
        {
            assert(Nod.Data == Typ);
            assert(@TypeOf(nod0).Data == Typ);
        }

        //+ Node `link()` and `unlink()` functions
        {
            assert(nod0.length() == 1);
            assert(nod1.length() == 1);
            assert(nod2.length() == 1);
            assert(nod3.length() == 1);
            assert(nod4.length() == 1);

            nod0.link(&nod1);
            nod0.link(&nod2);
            nod0.link(&nod3);
            nod0.link(&nod4);

            assert(nod0.length() == 5);
            assert(nod1.length() == 4);
            assert(nod2.length() == 3);
            assert(nod3.length() == 2);
            assert(nod4.length() == 1);

            nod0.unlink(&nod4);
            nod0.unlink(&nod3);
            nod0.unlink(&nod2);
            nod0.unlink(&nod1);

            assert(nod0.length() == 1);
            assert(nod1.length() == 1);
            assert(nod2.length() == 1);
            assert(nod3.length() == 1);
            assert(nod4.length() == 1);
        }

        //+ List `data` field type.
        {
            assert(Lst.Node.Data == Typ);
            assert(@TypeOf(lst0).Node.Data == Typ);
        }

        //+ List `insertLast()` and `removeLast()` functions
        {
            assert(lst0.length() == 0);
            assert(nod0.length() == 1);

            lst0.insertLast(&nod0);
            lst0.insertLast(&nod1);
            lst0.insertLast(&nod2);
            lst0.insertLast(&nod3);
            lst0.insertLast(&nod4);

            assert(lst0.length() == 5);
            assert(nod0.length() == 5);

            lst0.removeLast();
            lst0.removeLast();
            lst0.removeLast();
            lst0.removeLast();
            lst0.removeLast();

            assert(lst0.length() == 0);
            assert(nod0.length() == 1);
        }
    }
}
