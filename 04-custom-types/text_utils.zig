const std = @import("std");

pub const TextUtils = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) TextUtils {
        return TextUtils{
            .allocator = allocator,
        };
    }

    pub fn countWord(_: TextUtils, text: []const u8, word: []const u8) usize {
        var count: usize = 0;
        var i: usize = 0;

        while (i <= text.len - word.len) : (i += 1) {
            if (std.mem.eql(u8, text[i .. i + word.len], word)) {
                count += 1;
                i += word.len - 1;
            }
        }
        return count;
    }

    pub fn toLowerCase(self: *const TextUtils, text: []const u8) ![]u8 {
        var result = try self.allocator.alloc(u8, text.len);

        for (text, 0..) |char, i| {
            result[i] = if (char >= 'A' and char <= 'Z')
                char + ('a' - 'A')
            else
                char;
        }
        return result;
    }
};

pub fn main() !void {
    const term_out = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked == .leak) @panic("Shutdown due to memory leak");
    }
    const allocator = gpa.allocator();

    const utils = TextUtils.init(allocator);

    const text = "Oh, and she never gives out and she never gives in - She just changes her mind";

    const lowercase = try utils.toLowerCase(text);
    defer allocator.free(lowercase);

    const count = utils.countWord(lowercase, "she");

    try term_out.print("songtext in lowecase: {s}\n", .{lowercase});

    try term_out.print("\nIn this part of the songtext 'she' is counted {} times\n", .{count});
}
