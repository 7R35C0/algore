//:========================================================================
//: Licensed under the [MIT License](LICENSE).
//:
//: Tested with zig version 0.13.0 on Linux Fedora 39.
//:========================================================================

const std = @import("std");
const print = std.debug.print;

const SinglyLinkedList = @import("singly_linked_list").SinglyLinkedList;

pub fn main() !void {

    //+ Print the `data` field type of node.
    print("\n========================================\n", .{});
    {
        print("type: {any}\n", .{Nod.Data});
        print("type: {any}\n", .{Lst.Node.Data});

        print("type: {any}\n", .{@TypeOf(nod0).Data});
        print("type: {any}\n", .{@TypeOf(lst0).Node.Data});
    }

    // //+ An example with `node.link()` and `node.unlink()` functions
    // print("\n========================================\n", .{});
    // {
    //     resetNodes();
    //     linkNodes();
    //     printNodes();

    //     nod0.unlink(&nod2);
    //     printNodes();

    //     nod4.link(&nod0);
    //     printNodes();
    // }

    // //+ A more complex example with `node.reverse()` function
    // print("\n========================================\n", .{});
    // {
    //     resetNodes();
    //     linkNodes();
    //     printNodes();

    //     nod2.reverse();
    //     printNodes();
    // }

    // //+ A longer example with `node.link()` function and cycles in nodes
    // print("\n========================================\n", .{});
    // {
    //     resetNodes();
    //     printNodes();

    //     nod0.link(&nod1);
    //     nod1.link(&nod2);
    //     nod2.link(&nod3);
    //     printNodes();

    //     nod3.link(&nod1);
    //     printNodes();

    //     nod3.unlink(&nod1);
    //     printNodes();

    //     nod0.link(&nod4);
    //     printNodes();
    // }
}

//+--------------------------------------------------------------
//+ Helpers
//+--------------------------------------------------------------

const Typ = usize;
const Lst = SinglyLinkedList(Typ);
const Nod = Lst.Node;

var nod0 = Nod{ .data = 0, .next = null };
var nod1 = Nod{ .data = 1, .next = null };
var nod2 = Nod{ .data = 2, .next = null };
var nod3 = Nod{ .data = 3, .next = null };
var nod4 = Nod{ .data = 4, .next = null };

var tst0 = Nod{ .data = 0, .next = null };
var tst1 = Nod{ .data = 1, .next = null };
var tst2 = Nod{ .data = 2, .next = null };
var tst3 = Nod{ .data = 3, .next = null };
var tst4 = Nod{ .data = 4, .next = null };

var lst0 = Lst{};
// var lst1 = Lst{};
// var lst2 = Lst{};
// var lst3 = Lst{};
// var lst4 = Lst{};

const cnt = 15;

fn resetNodes() void {
    nod0 = Nod{ .data = 0, .next = null };
    nod1 = Nod{ .data = 1, .next = null };
    nod2 = Nod{ .data = 2, .next = null };
    nod3 = Nod{ .data = 3, .next = null };
    nod4 = Nod{ .data = 4, .next = null };
}

fn linkNodes() void {
    nod0.link(&nod1);
    nod1.link(&nod2);
    nod2.link(&nod3);
    nod3.link(&nod4);
}

fn printNodes() void {
    print("\n", .{});
    nod0.printNode("nod0", cnt);
    nod1.printNode("nod1", cnt);
    nod2.printNode("nod2", cnt);
    nod3.printNode("nod3", cnt);
    nod4.printNode("nod4", cnt);
}

fn resetTests() void {
    tst0 = Nod{ .data = 0, .next = null };
    tst1 = Nod{ .data = 1, .next = null };
    tst2 = Nod{ .data = 2, .next = null };
    tst3 = Nod{ .data = 3, .next = null };
    tst4 = Nod{ .data = 4, .next = null };
}

fn linkTests() void {
    tst0.link(&tst1);
    tst1.link(&tst2);
    tst2.link(&tst3);
    tst3.link(&tst4);
}

fn printTests() void {
    print("\n", .{});
    tst0.printNode("tst0", cnt);
    tst1.printNode("tst1", cnt);
    tst2.printNode("tst2", cnt);
    tst3.printNode("tst3", cnt);
    tst4.printNode("tst4", cnt);
}

fn resetLists() void {
    lst0.head = null;
    // lst1.head = null;
    // lst2.head = null;
    // lst3.head = null;
    // lst4.head = null;
}

fn printLists() void {
    print("\n", .{});
    lst0.printList("lst0", cnt);
    // lst1.printList("lst1", cnt);
    // lst2.printList("lst2", cnt);
    // lst3.printList("lst3", cnt);
    // lst4.printList("lst4", cnt);
}
