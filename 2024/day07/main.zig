const std = @import("std");
const print = std.debug.print;
const gpa = @import("gpa.zig").allocator;

const input = @embedFile("input.txt");

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var list = std.ArrayList([]u64).init(gpa);
    defer list.deinit();

    var result1: u64 = 0;
    var result2: u64 = 0;

    while (lines.next()) |line| {
        const numbers = try parseLine(line);
        const total = numbers[0];
        const max: usize = 1 << 16;
        for (0..max) |op| {
            if (attempt(total, numbers[1..], op)) {
                result1 += total;
                break;
            }
        }
        if (attemptx(total, numbers[1], numbers[2..])) {
            // if (isValidCalibration(numbers[0], numbers, numbers[1], 1)) {
            result2 += total;
        }
    }

    print("Result 1: {d}\n", .{result1});
    print("Result 2: {d}\n\n", .{result2});
}

fn attempt(total: u64, numbers: []const u64, operators: usize) bool {
    var o = operators;
    var t: u64 = numbers[0];
    var i: usize = 1;
    while (i < numbers.len) : (i += 1) {
        if (o & 1 == 1) {
            t = t * numbers[i];
        } else {
            t = t + numbers[i];
        }
        o = o >> 1;
    }
    return t == total;
}

fn attemptx(needle: u64, total: u64, numbers: []const u64) bool {
    if (numbers.len == 0) return needle == total;

    return (attemptx(needle, total + numbers[0], numbers[1..])) or
        (attemptx(needle, total * numbers[0], numbers[1..])) or
        (attemptx(needle, concat(total, numbers[0]), numbers[1..]));
}

fn concat(l: u64, r: u64) u64 {
    var n = r;
    var x = l;

    while (n > 0) : (n /= 10) {
        x *= 10;
    }
    return x + r;
}

fn parseLine(line: []const u8) ![]const u64 {
    var list = std.ArrayList(u64).init(gpa);
    defer list.deinit();

    var parts = std.mem.splitScalar(u8, line, ' ');
    while (parts.next()) |part| {
        const trimmed = std.mem.trim(u8, part, " :\r\n\t");
        const number = try std.fmt.parseInt(u64, trimmed, 10);
        try list.append(number);
    }
    return try gpa.dupe(u64, list.items);
}
