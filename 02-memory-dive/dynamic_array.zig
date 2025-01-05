const std = @import("std");

pub fn main() !void {
    const term_out = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leakchk = gpa.deinit();
        if (leakchk == .leak) @panic("Shutting down due to memory leak");
    }
    const allocator = gpa.allocator();

    var list = std.ArrayList(i32).init(allocator);
    defer list.deinit();

    try list.append(42);
    try list.append(43);
    try list.append(44);

    try term_out.print("Our Dynamic Array: {any}\n", .{list.items});
    try term_out.print("Länge: {}\n", .{list.items.len});
}
