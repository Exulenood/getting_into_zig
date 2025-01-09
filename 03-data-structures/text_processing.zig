const std = @import("std");

fn countWord(text: []const u8, word: []const u8) usize {
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

pub fn main() !void {
    const term_out = std.io.getStdOut().writer();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked == .leak) @panic("Shutdown due to memory leak");
    }
    const allocator = gpa.allocator();

    const text =
        \\ May the force be with you
        \\ He is chosen by the force
        \\ Believe in the force
    ;

    const searchWord = "force";
    const count = countWord(text, searchWord);

    try term_out.print("The word {s} is counted {} times\n", .{ searchWord, count });

    var lowercase = try allocator.alloc(u8, text.len);
    defer allocator.free(lowercase);

    for (text, 0..) |char, i| {
      lowercase[i] = if (char >= 'A' and char <= 'Z')
      char + ('a' - 'A')
      else char;
    }

    try term_out.print("\n Text in lowercase: \n{s}\n", .{lowercase});
}
