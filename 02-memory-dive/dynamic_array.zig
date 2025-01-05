const std = @import("std");

pub fn main() !void {
    const term_out = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leakchk = gpa.deinit();
        if (leakchk == .leak) @panic("Shutting down due to memory leak");
    }
    const allocator = gpa.allocator();

    var list = try std.ArrayList(i32).initCapacity(allocator, 5);
    defer list.deinit();

    try term_out.print("\n\nFilling array:\n\n", .{});

    var i: i32 = 10;
    while (i < 20) : (i += 1) {
        try list.append(i);
        try term_out.print("After append with {}:\nlenght={}\ncapacity={}\n", .{ i, list.items.len, list.capacity });
    }

    try term_out.print("\n\nIteration Operations:\n\n1. by Index:\n", .{});
    for (list.items, 0..) |value, index| {
        try term_out.print("Value for Index {} = {}\n", .{ index, value });
    }

    try term_out.print("\n\n2. by Values:\n", .{});
    for (list.items) |value| {
        try term_out.print("Value {}\n", .{value});
    }

    try term_out.print("\n\n3. mutating (values * 2):\n", .{});
    for (list.items) |*value| {
        value.* *= 2;
    }
    try term_out.print("List after mutating iteration{any}\n", .{list.items});

    try term_out.print("\n\nRemove Operations:\n\n", .{});

    _ = list.orderedRemove(1);
    try term_out.print("After an ordered remove, value on index 1 is taken out and all following values moved in by 1 index: {any}\n", .{list.items});

    _ = list.swapRemove(0);
    try term_out.print("After a swap remove, value on index 0 is taken out and replaced by value of the last index: {any}\n", .{list.items});

    try term_out.print("\n\nCapacity Operations:\n\n", .{});

    try list.ensureTotalCapacity(20);
    try term_out.print("After ensureTotalCapacity:\nitems={any}\ncapacity={}\n", .{ list.items, list.capacity });

    list.shrinkAndFree(list.items.len);
    try term_out.print("After shrinkAndFree:\nitems={any}\ncapacity={}\n", .{ list.items, list.capacity });
}
