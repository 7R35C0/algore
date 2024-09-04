const std = @import("std");

const LookupTable = @import("generate_lookup_table").LookupTable;

pub fn main() !void {
    const table = LookupTable(128).generate();

    const file = try std.fs.cwd().createFile(
        "LookupTable.txt",
        .{
            .read = true,
            .truncate = true,
        },
    );
    defer file.close();

    try file.writer().print("{}\n", .{table});
}
