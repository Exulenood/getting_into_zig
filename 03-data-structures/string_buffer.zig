const std = @import("std");

pub fn main() !void {
    const term_out = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked == .leak) @panic("Shutdown due to memory leak");
    }
    const allocator = gpa.allocator();

    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    try buffer.appendSlice("First Line\n");
    try buffer.appendSlice("Second Line\n");
    try buffer.appendSlice("Third Line\n");

    try term_out.print("Buffer contains:\n{s}", .{buffer.items});

    var lines = std.mem.split(u8, buffer.items, "\n");
    var line_number: usize = 1;

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        try term_out.print("Line {}: {s}\n", .{ line_number, line });
        line_number += 1;
    }

    buffer.clearRetainingCapacity();
    try buffer.appendSlice("All Lines cleared here");

    try term_out.print("\nBuffer contains now:\n{s}\n", .{buffer.items});
}
