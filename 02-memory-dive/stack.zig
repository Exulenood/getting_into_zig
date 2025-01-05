const std = @import("std");

pub fn main() !void {
    var stackArray: [3]i32 = [_]i32{ 1, 2, 3 };

    stackArray[0] = 42;
    try std.io.getStdOut().writer().print("Array on our Stack: {any}\n", .{stackArray});
}
