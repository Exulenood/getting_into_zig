const std = @import("std");

const CalculatorError = error{
    DivisionByZero,
};

const Operation = enum {
    add,
    subtract,
    multiply,
    divide,

    pub fn symbol(self: Operation) []const u8 {
        return switch (self) {
            .add => "+",
            .subtract => "-",
            .multiply => "*",
            .divide => "/",
        };
    }
};

pub fn main() !void {
    const termOut = std.io.getStdOut().writer();
    const termIn = std.io.getStdIn().reader();
    var calcBuffer: [100]u8 = undefined;

    try termOut.print("First Value: ", .{});
    const value1 = try getNumber(termIn, &calcBuffer);

    const operation = while (true) {
        try termOut.print("Operation (enter +, -, * or /): ", .{});

        const effectiveOperation = getOperation(termIn, &calcBuffer) catch {
            try termOut.print("Please enter a valid Operation!\n", .{});
            continue;
        };
        break effectiveOperation;
    };

    try termOut.print("Second Value: ", .{});
    const value2 = try getNumber(termIn, &calcBuffer);

    const result = calculate(value1, value2, operation) catch |err| {
        switch (err) {
            CalculatorError.DivisionByZero => try termOut.print("Unable to do a div/0!\n", .{}),
        }
        return;
    };

    try termOut.print("{} {s} {} = {}\n", .{ value1, operation.symbol(), value2, result });
}

fn getNumber(reader: std.fs.File.Reader, calcBuffer: []u8) !i32 {
    if (reader.readUntilDelimiter(calcBuffer[0..], '\n')) |input| {
        return std.fmt.parseInt(i32, input, 10);
    } else |err| {
        return err;
    }
}

fn getOperation(reader: std.fs.File.Reader, calcBuffer: []u8) !Operation {
    if (reader.readUntilDelimiter(calcBuffer[0..], '\n')) |input| {
        return switch (input[0]) {
            '+' => .add,
            '-' => .subtract,
            '*' => .multiply,
            '/' => .divide,
            else => error.InvalidOperation,
        };
    } else |err| {
        return err;
    }
}

fn calculate(value1: i32, value2: i32, operation: Operation) !i32 {
    return switch (operation) {
        .add => value1 + value2,
        .subtract => value1 - value2,
        .multiply => value1 * value2,
        .divide => if (value2 == 0) error.DivisionByZero else @divTrunc(value1, value2),
    };
}
