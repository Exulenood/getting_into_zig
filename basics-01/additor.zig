const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    var calcBuffer: [100]u8 = undefined;

    try stdout.print("Enter a number: ", .{});

    if (stdin.readUntilDelimiter(calcBuffer[0..], '\n')) |input| {
        const number = std.fmt.parseInt(i32, input, 10) catch |err| {
          try stdout.print("This was not a valid number ({!})\n", .{err});
          return;
        };
        try stdout.print("Your Number plus 100 is: {}\n", .{number + 100});
    } else |err| {
      try stdout.print("Error while reading: {!}\n", .{err});
    }
}
