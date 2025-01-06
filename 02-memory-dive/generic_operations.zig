const std = @import("std");

fn map(
    comptime T: type,
    comptime U: type,
    allocator: std.mem.Allocator,
    items: []const T,
    transform: fn (T) U,
) !std.ArrayList(U) {
    var result = std.ArrayList(U).init(allocator);
    try result.ensureTotalCapacity(items.len);

    for (items) |item| {
        try result.append(transform(item));
    }

    return result;
}

fn filter(
    comptime T: type,
    allocator: std.mem.Allocator,
    items: []const T,
    condition: fn (T) bool,
) !std.ArrayList(T) {
    var result = std.ArrayList(T).init(allocator);

    for (items) |item| {
        if (condition(item)) {
            try result.append(item);
        }
    }
    return result;
}

fn double(n: i32) i32 {
    return n * 2;
}

fn toString(n: i32) []const u8 {
    return switch (n) {
        1 => "one",
        2 => "two",
        3 => "three",
        4 => "four",
        5 => "five",
        6 => "six",
        7 => "seven",
        8 => "eight",
        9 => "nine",
        10 => "ten",
        11 => "eleven",
        12 => "twelve",
        else => "other",
    };
}

fn isEven(n: i32) bool {
  return @rem(n, 2) == 0;
}

pub fn main() !void {
    const term_out = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked == .leak) @panic("Shutdown due to memory leak");
    }
    const allocator = gpa.allocator();

    var numbers = std.ArrayList(i32).init(allocator);
    defer numbers.deinit();

    for (0..13) |i| {
        try numbers.append(@intCast(i + 1));
    }

    var doubled = try map(i32, i32, allocator, numbers.items, double);
    defer doubled.deinit();

    var strings = try map(i32, []const u8, allocator, numbers.items, toString);
    defer strings.deinit();

    var evens = try filter(i32, allocator,numbers.items, isEven);
    defer evens.deinit();

    try term_out.print("Original numbers: {any}\n", .{numbers.items});
    try term_out.print("Doubled numbers: {any}\n", .{doubled.items});
    try term_out.print("Stringified numbers: {s}\n", .{strings.items});
    try term_out.print("Even numbers: {any}\n", .{evens.items});
}
