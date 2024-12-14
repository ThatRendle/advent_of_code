const std = @import("std");

const Status = enum { safe, unsafe, invalid };

fn loadData(allocator: std.mem.Allocator) ![]u8 {
    const cwd = std.fs.cwd();
    const file = try cwd.openFile("data.txt", .{ .mode = .read_only });
    defer file.close();

    const stat = try file.stat();
    const reader = file.reader();

    return try reader.readAllAlloc(allocator, stat.size);
}

fn tryDescending(first: i32, tokens: *std.mem.TokenIterator(u8, .any)) !Status {
    var n = first;
    while (tokens.next()) |token| {
        const next = try std.fmt.parseInt(i32, token, 10);
        if (next >= n) return Status.unsafe;
        if (n - next > 3) return Status.unsafe;
        n = next;
    }
    return Status.safe;
}

fn tryAscending(first: i32, tokens: *std.mem.TokenIterator(u8, .any)) !Status {
    var n = first;
    while (tokens.next()) |token| {
        const next = try std.fmt.parseInt(i32, token, 10);
        if (next <= n) return Status.unsafe;
        if (next - n > 3) return Status.unsafe;
        n = next;
    }
    return Status.safe;
}

fn check(line: []const u8) !Status {
    var tokens = std.mem.tokenize(u8, line, " ");
    const firstToken = tokens.next().?;
    const f = try std.fmt.parseInt(i32, firstToken, 10);
    const secondToken = tokens.next().?;
    const s = try std.fmt.parseInt(i32, secondToken, 10);
    if (f == s) return Status.unsafe;
    if (f < s) return try tryAscending(s, &tokens);
    return try tryDescending(s, &tokens);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const data = try loadData(allocator);
    defer allocator.free(data);

    var lines = std.mem.split(u8, data, "\n");

    var safe: i32 = 0;

    while (lines.next()) |line| {
        if (try check(line) == Status.safe) {
            safe += 1;
        }
    }

    std.debug.print("{d}", .{safe});
}
