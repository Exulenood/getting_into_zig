const std = @import("std");

pub fn main() !void {
    const term_out = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked == .leak) @panic("Shutdown due to memory leak");
    }
    const allocator = gpa.allocator();

    const first_string = "My life for";

    try term_out.print("Length of string: {}\n", .{first_string.len});

    const slice = first_string[0..2];
    try term_out.print("\nfirst two characters of string: {s}", .{slice});

    const second_string = "Aiur";
    const full_battlecry = try std.fmt.allocPrint(allocator, "{s} {s}!", .{ first_string, second_string });
    defer allocator.free(full_battlecry);

    try term_out.print("\nMy battlecry: {s}\n", .{full_battlecry});
}
