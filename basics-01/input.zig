const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    var buffer: [100]u8 = undefined;

    try stdout.print("Whats your name? ", .{});

    if (stdin.readUntilDelimiter(buffer[0..], '\n')) |name| {
        if (name.len == 0) {
            try stdout.print("You forgot to enter a name! ", .{});
            return;
        }
        try stdout.print("Then {s} it is!\n", .{name});
    } else |err| {
        try stdout.print("Error: {!}\n", .{err});
    }
}
