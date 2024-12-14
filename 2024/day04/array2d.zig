const std = @import("std");

pub fn create_empty(allocator: std.mem.Allocator, rows: usize, cols: usize) ![][]u8 {
    const grid = try allocator.alloc([]u8, rows);

    for (0..rows) |r| {
        grid[r] = try allocator.alloc(u8, cols);
    }

    return grid;
}
