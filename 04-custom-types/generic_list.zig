const std = @import("std");

pub fn List(comptime T: type) type {
    return struct {
        items: std.ArrayList(T),

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .items = std.ArrayList(T).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.items.deinit();
        }

        pub fn append(self: *Self, item: T) !void {
            try self.items.append(item);
        }

        pub fn get(self: Self, index: usize) ?T {
            if (index >= self.items.items.len) return null;
            return self.items.items[index];
        }

        pub fn len(self: Self) usize {
            return self.items.items.len;
        }
    };
}
pub fn main() !void {
    const termOut = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked == .leak) @panic("Shutdown due to memory leak");
    }

    const allocator = gpa.allocator();

    var numbers = List(i32).init(allocator);
    defer numbers.deinit();

    try numbers.append(1981);
    try numbers.append(2011);
    try numbers.append(2023);

    var names = List([]const u8).init(allocator);
    defer names.deinit();

    try names.append("Liara");
    try names.append("Wrex");
    try names.append("Garrus");

    try termOut.print("Numbers: ", .{});
    var i: usize = 0;
    while (i < numbers.len()) : (i += 1) {
        if (numbers.get(i)) |num| {
            try termOut.print("{} ", .{num});
        }
    }

    try termOut.print("\nNames: ", .{});
    i = 0;
    while (i < names.len()) : (i += 1) {
        if (names.get(i)) |name| {
            try termOut.print("{s} ", .{name});
        }
    }

    try termOut.print("\n", .{});
}
