const std = @import("std");

pub fn main() !void {
    const term_out = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked == .leak) @panic("Shutdown due to memory leak");
    }
    const allocator = gpa.allocator();

    var scores = std.StringHashMap(i32).init(allocator);
    defer scores.deinit();

    try scores.put("Nerzul", 100);
    try scores.put("Arthas", 75);
    try scores.put("Sylvanas", 95);

    if (scores.get("Nerzul")) |score| {
        try term_out.print("\nNerzul's score: {}\n", .{score});
    }

    try term_out.print("\nAmount of entries: {}\n", .{scores.count()});

    try scores.put("Nerzul", 65);

    var iterator = scores.iterator();
    while (iterator.next()) |entry| {
        try term_out.print("{s}: {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    if (scores.contains("Arthas")) {
        try term_out.print("\nArthas is in the list!\n", .{});
    }

    _ = scores.remove("Arthas");

    var keyIterator = scores.keyIterator();
    try term_out.print("\nAll Names:\n", .{});
    while (keyIterator.next()) |key| {
      try term_out.print("{s}\n", .{key.*});
    }
}
