const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const expectEqualSlices = std.testing.expectEqualSlices;

pub const Rule = struct {
    first: usize,
    second: usize,

    pub fn run(self: *const @This(), line: []usize) bool {
        const first_index = std.mem.indexOfScalar(usize, line, self.first);
        if (first_index == null) return true;
        const second_index = std.mem.indexOfScalar(usize, line, self.second);
        if (second_index == null) return true;
        return second_index.? > first_index.?;
    }

    pub fn fix(self: *const @This(), line: []usize) bool {
        const first_index = std.mem.indexOfScalar(usize, line, self.first);
        if (first_index == null) return false;
        const second_index = std.mem.indexOfScalar(usize, line, self.second);
        if (second_index == null) return false;
        if (second_index.? > first_index.?) return false;

        std.mem.swap(usize, &line[first_index.?], &line[second_index.?]);
        if (!self.fix(line)) return true;
        return true;
    }

    pub fn create(first: usize, second: usize) Rule {
        return Rule{ .first = first, .second = second };
    }
};

test "fixes" {
    const allocator = std.testing.allocator;
    const rule = Rule{ .first = 97, .second = 75 };
    const actual = [_]usize{ 75, 97, 47, 61, 53 };
    const expected = [_]usize{ 97, 75, 47, 61, 53 };

    const a = try allocator.dupe(usize, &actual);
    defer allocator.free(a);
    const e: []usize = try allocator.dupe(usize, &expected);
    defer allocator.free(e);

    try expect(rule.fix(a));
    try expectEqualSlices(usize, e, a);
}
