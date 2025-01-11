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

        pub fn remove(self: *Self, index: usize) ?T {
            if (index >= self.items.items.len) return null;
            return self.items.orderedRemove(index);
        }

        pub fn find(self: Self, item: T, comptime eql: fn (T, T) bool) ?usize {
            for (self.items.items, 0..) |current, i| {
                if (eql(current, item)) return i;
            }
            return null;
        }

        pub fn map(self: Self, allocator: std.mem.Allocator, comptime U: type, transform: fn (T) U) !List(U) {
            var result = List(U).init(allocator);
            for (self.items.items) |item| {
                try result.append(transform(item));
            }
            return result;
        }

        pub fn filter(self: Self, allocator: std.mem.Allocator, predicate: fn (T) bool) !Self {
            var result = Self.init(allocator);
            for (self.items.items) |item| {
                if (predicate(item)) {
                    try result.append(item);
                }
            }
            return result;
        }
    };
}

fn eqlInt(a: i32, b: i32) bool {
    return a == b;
}

fn eqlString(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

fn fromEighyOne(n: i32) i32 {
    return n - 1981;
}

fn isEven(n: i32) bool {
    return @rem(n, 2) == 0;
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
    try numbers.append(1990);
    try numbers.append(2011);
    try numbers.append(2023);
    try numbers.append(2024);

    var names = List([]const u8).init(allocator);
    defer names.deinit();

    try termOut.print("Original years: ", .{});
    var i: usize = 0;
    while (i < numbers.len()) : (i += 1) {
        if (numbers.get(i)) |year| {
            try termOut.print("{} ", .{year});
        }
    }

    if (numbers.find(2023, eqlInt)) |index| {
        try termOut.print("\nFound 2023 at index: {}", .{index});
    }

    var yearsFromEightyOne = try numbers.map(allocator, i32, fromEighyOne);
    defer yearsFromEightyOne.deinit();

    try termOut.print("\nYears count from 1981:", .{});
    for (yearsFromEightyOne.items.items) |year| {
        try termOut.print("{} ", .{year});
    }

    var evens = try numbers.filter(allocator, isEven);
    defer evens.deinit();

    try termOut.print("\nEven years:", .{});
    for (evens.items.items) |year| {
        try termOut.print("{} ", .{year});
    }
    
    try names.append("Liara");
    try names.append("Wrex");
    try names.append("Garrus");

    try termOut.print("\n\nNames: ", .{});
    i = 0;
    while (i < names.len()) : (i += 1) {
        if (names.get(i)) |name| {
            try termOut.print("{s} ", .{name});
        }
    }

    try termOut.print("\n", .{});
}
