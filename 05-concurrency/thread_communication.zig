const std = @import("std");

const Message = struct {
    mutex: std.Thread.Mutex,
    value: i32,

    fn init() Message {
        return Message{ .mutex = std.Thread.Mutex{}, .value = 0 };
    }
};

fn incrementThread(message: *Message) void {
    var i: usize = 0;

    while (i < 1000) : (i += 1) {
        message.mutex.lock();
        defer message.mutex.unlock();

        message.value += 1;
        std.time.sleep(1);
    }
}

pub fn main() !void {
    var message = Message.init();

    var threads: [2]std.Thread = undefined;

    for (0..2) |i| {
        threads[i] = try std.Thread.spawn(.{}, incrementThread, .{&message});
    }

    std.debug.print("Threads started with initial value: {}\n", .{message.value});

    for (threads) |thread| {
        thread.join();
    }

    std.debug.print("Threads closed with final value: {}\n", .{message.value});
}
