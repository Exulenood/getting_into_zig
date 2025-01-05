const std = @import("std");

fn double(n: i32) i32 {
    return n * 2;
}

fn isEven(n: i32) bool {
    return @rem(n, 2) == 0;
}

pub fn main() !void {
    const term_out = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const clear = gpa.deinit();
        if (clear == .leak) @panic("Shutdown due to memory leak!");
    }
    const allocator = gpa.allocator();

    var list = std.ArrayList(i32).init(allocator);
    defer list.deinit();

    for (0..10) |i| {
        try list.append(@intCast(i + 1));
    }

    try term_out.print("\nOriginal list: {any}\n", .{list.items});

    var mapped = std.ArrayList(i32).init(allocator);
    defer mapped.deinit();

    for (list.items) |value| {
        try mapped.append(double(value));
    }

    try term_out.print("\nMapped list with doubled values: {any}\n", .{mapped.items});

    var filtered = std.ArrayList(i32).init(allocator);
    defer filtered.deinit();

    for (list.items) |value| {
        if (isEven(value)) {
            try filtered.append(value);
        }
    }

    try term_out.print("\nFiltered list with omitted uneven values: {any}\n\n", .{filtered.items});
}
