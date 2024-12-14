const std = @import("std");

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

    pub fn create(first: usize, second: usize) Rule {
        return Rule{ .first = first, .second = second };
    }
};
