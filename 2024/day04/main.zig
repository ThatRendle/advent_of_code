const std = @import("std");
const array2d = @import("array2d.zig");

const print = std.debug.print;

const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitScalar(u8, input, '\n');
    var list = std.ArrayList([]u8).init(allocator);
    while (lines.next()) |line| {
        try list.append(try allocator.dupe(u8, line));
    }

    const row_count: usize = list.items.len + 6;
    const column_count: usize = list.items[0].len + 6;

    const grid = try array2d.create_empty(u8, allocator, row_count, column_count);

    for (list.items, 0..) |line, n| {
        const dest = grid[n + 3][3..];
        std.mem.copyForwards(u8, dest, line);
    }

    const xmas_count = part_one(grid);
    const x_mas_count = part_two(grid);

    print("\n{d} XMASes\n\n", .{xmas_count});
    print("\n{d} X-MASes\n\n", .{x_mas_count});
}

fn part_one(grid: [][]u8) i32 {
    var count: i32 = 0;

    var r: usize = 3;
    while (r < grid.len - 3) : (r += 1) {
        var c: usize = 3;
        while (c < grid[r].len - 3) : (c += 1) {
            if (grid[r][c] == 'X') {
                if (check_xmas(grid, r, c, sub, sub)) count += 1;
                if (check_xmas(grid, r, c, sub, nop)) count += 1;
                if (check_xmas(grid, r, c, sub, add)) count += 1;
                if (check_xmas(grid, r, c, nop, sub)) count += 1;
                if (check_xmas(grid, r, c, nop, add)) count += 1;
                if (check_xmas(grid, r, c, add, sub)) count += 1;
                if (check_xmas(grid, r, c, add, nop)) count += 1;
                if (check_xmas(grid, r, c, add, add)) count += 1;
            }
        }
    }

    return count;
}

fn part_two(grid: [][]u8) i32 {
    var count: i32 = 0;

    var r: usize = 3;
    while (r < grid.len - 3) : (r += 1) {
        var c: usize = 3;
        while (c < grid[r].len - 3) : (c += 1) {
            if (grid[r][c] == 'A') {
                if (check_x_mas(grid, r, c)) count += 1;
            }
        }
    }

    return count;
}

// MMMMM
// MAAAM
// SSSSS

fn check_x_mas(grid: [][]u8, row: usize, col: usize) bool {
    const tl = grid[row - 1][col - 1];
    const tr = grid[row - 1][col + 1];
    const bl = grid[row + 1][col - 1];
    const br = grid[row + 1][col + 1];

    if (check_neighbours(tl, br)) {
        if (check_neighbours(tr, bl)) return true;
    }

    return false;
}

fn check_neighbours(a: u8, b: u8) bool {
    if (a == 'M' and b == 'S') return true;
    if (a == 'S' and b == 'M') return true;
    return false;
}

fn check_xmas(grid: [][]u8, row: usize, col: usize, rf: fn (x: usize) usize, cf: fn (x: usize) usize) bool {
    var r = rf(row);
    var c = cf(col);
    if (grid[r][c] != 'M') return false;
    r = rf(r);
    c = cf(c);
    if (grid[r][c] != 'A') return false;
    r = rf(r);
    c = cf(c);
    return grid[r][c] == 'S';
}

fn add(x: usize) usize {
    return x + 1;
}
fn nop(x: usize) usize {
    return x;
}
fn sub(x: usize) usize {
    return x - 1;
}

// fn check_cell(grid: [][]u8, row: i32, col: i32, char: u8) bool {
//     const r: usize = @intCast(row);
//     const c: usize = @intCast(col);
//     print("check_cell {d},{d}", .{ r, c });
//     return grid[r][c] == char;
// }
