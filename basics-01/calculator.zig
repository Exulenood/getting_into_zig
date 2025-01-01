const std = @import("std");

pub fn main() !void {
    const termOut = std.io.getStdOut().writer();
    const termIn = std.io.getStdIn().reader();
    var calcBuffer: [100]u8 = undefined;

    try termOut.print("First Value: ", .{});
    const value1 = try getNumber(termIn, &calcBuffer);

    try termOut.print("Second Value: ", .{});
    const value2 = try getNumber(termIn, &calcBuffer);

    const sum = value1 + value2;
    try termOut.print("{} + {} = {}\n", .{ value1, value2, sum });
}

fn getNumber(reader: anytype, calcBuffer: []u8) !i32 {
    if (reader.readUntilDelimiter(calcBuffer[0..], '\n')) |input| {
        return std.fmt.parseInt(i32, input, 10);
    } else |err| {
        return err;
    }
}
