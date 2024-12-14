const std = @import("std");

pub fn create_empty(comptime T: type, allocator: std.mem.Allocator, rows: usize, cols: usize) ![][]T {
    const grid = try allocator.alloc([]u8, rows);

    for (0..rows) |r| {
        grid[r] = try allocator.alloc(T, cols);
    }

    return grid;
}
