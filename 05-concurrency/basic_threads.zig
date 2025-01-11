const std = @import("std");

fn threadFunction(value: usize) void {
    std.time.sleep(1 * std.time.ns_per_s);
    std.debug.print("Thread {}: Executed!\n", .{value});
}

pub fn main() !void {
    var threads: [3]std.Thread = undefined;

    for (0..3) |i| {
        threads[i] = try std.Thread.spawn(.{}, threadFunction, .{i});
    }

    std.debug.print("all threads started!\n", .{});

    for (threads) |thread| {
        thread.join();
    }

    std.debug.print("all threads closed!\n", .{});
}
