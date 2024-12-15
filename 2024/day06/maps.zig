const std = @import("std");

pub fn load(data: []const u8, allocator: std.mem.Allocator) !Map {
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    var width: usize = 0;
    for (data, 0..) |c, i| {
        if (c == '\n') {
            if (width == 0) width = i;
            continue;
        }
        try list.append(c);
    }

    const result = try allocator.dupe(u8, list.items);
    return Map{ .data = result, .width = width, .height = result.len / width };
}

pub const Map = struct {
    data: []u8,
    width: usize,
    height: usize,

    pub fn get(self: *const @This(), row: usize, col: usize) u8 {
        const index = (row * self.width) + col;
        return self.data[index];
    }

    pub fn set(self: *const @This(), row: usize, col: usize, value: u8) void {
        const index = (row * self.width) + col;
        self.data[index] = value;
    }

    pub fn find(self: *const @This(), value: u8) ?Point {
        const index = std.mem.indexOfScalarPos(u8, self.data, 0, value);
        if (index == null) return null;
        const row = index.? / self.width;
        const col = index.? % self.width;
        return Point{ .row = row, .col = col };
    }
};

pub const Point = struct { row: usize, col: usize };

test "parses_map" {
    const expectEqual = std.testing.expectEqual;
    const allocator = std.testing.allocator;
    const input = @embedFile("example.txt");
    const actual = try load(input, allocator);
    defer allocator.free(actual.data);

    const expected = "....#..............#............#..............#.............#..^.............#.#...............#...";

    try expectEqual(10, actual.width);
    try expectEqual(10, actual.height);
    try std.testing.expectEqualSlices(u8, expected, actual.data);
    try expectEqual('#', actual.get(3, 2));
    const p = actual.find('^').?;
    try expectEqual(6, p.row);
    try expectEqual(4, p.col);
}
