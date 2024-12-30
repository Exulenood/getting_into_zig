const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    var buffer: [100]u8 = undefined;

    try stdout.print("Whats your name? ", .{});

    if (stdin.readUntilDelimiter(buffer[0..], '\n')) |name| {
        try stdout.print("Then {s} it is!\n", .{name});
    } else |err| {
        try stdout.print("Error: {!}\n", .{err});
    }
}
