const std = @import("std");

const ThreadSafeQueue = struct {
    mutex: std.Thread.Mutex,
    items: std.ArrayList(i32),

    fn init(allocator: std.mem.Allocator) ThreadSafeQueue {
        return ThreadSafeQueue{ .mutex = std.Thread.Mutex{}, .items = std.ArrayList(i32).init(allocator) };
    }

    fn deinit(self: *ThreadSafeQueue) void {
        self.items.deinit();
    }

    fn push(self: *ThreadSafeQueue, value: i32) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        try self.items.append(value);
    }

    fn pop(self: *ThreadSafeQueue) ?i32 {
        self.mutex.lock();
        defer self.mutex.unlock();
        if (self.items.items.len == 0) return null;
        return self.items.orderedRemove(0);
    }
};

fn producerThread(queue: *ThreadSafeQueue) !void {
    var i: i32 = 0;
    while (i < 10) : (i += 1) {
        try queue.push(i);
        std.debug.print("Produced => : {}\n", .{i});
        std.time.sleep(100 * std.time.ns_per_ms);
    }
}

fn consumerThread(queue: *ThreadSafeQueue) void {
    var count: usize = 0;
    while (count < 10) {
        if (queue.pop()) |value| {
            std.debug.print("Consumed <=: {}\n", .{value});
            count += 1;
        }
        std.time.sleep(150 * std.time.ns_per_ms);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer {
        const leakchk = gpa.deinit();
        if (leakchk == .leak) @panic("Shutdown due to memory leak");
    }
    const allocator = gpa.allocator();

    var queue = ThreadSafeQueue.init(allocator);
    defer queue.deinit();

    const producer = try std.Thread.spawn(.{}, producerThread, .{&queue});
    const consumer = try std.Thread.spawn(.{}, consumerThread, .{&queue});

    producer.join();
    consumer.join();

    std.debug.print("All operations closed!\n", .{});
}
