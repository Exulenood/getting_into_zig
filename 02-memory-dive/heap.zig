const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leakchk = gpa.deinit(); // we could also dismiss this dirty with defer _ = gpa.deinit();
        if (leakchk == .leak) {
            @panic("Memory leak detected!");
        }
    }
    const allocator = gpa.allocator();

    var heapArray = try allocator.alloc(i32, 3);

    defer allocator.free(heapArray);

    heapArray[0] = 42;
    heapArray[1] = 43;
    heapArray[2] = 44;

    try std.io.getStdOut().writer().print("Array on the heap: {any}\n", .{heapArray});
}
