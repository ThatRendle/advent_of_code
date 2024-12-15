const std = @import("std");
const print = std.debug.print;
const gpa = @import("gpa.zig").allocator;

const maps = @import("maps.zig");

const input = @embedFile("input.txt");

pub fn main() !void {
    const map = try maps.load(input, gpa);
    const empty = try gpa.alloc(u8, map.data.len);
    const path = maps.Map{ .data = empty, .width = map.width, .height = map.height };

    const start_pos = map.find('^').?;
    var row = start_pos.row;
    var col = start_pos.col;

    path.set(row, col, 'X');

    var d: usize = 0;

    while (true) {
        switch (d) {
            0 => {
                if (row == 0) {
                    path.set(row, col, 'X');
                    break;
                }
                if (map.get(row - 1, col) == '#') {
                    d = 90;
                } else {
                    path.set(row, col, 'X');
                    row -= 1;
                }
            },
            90 => {
                if (col + 1 == map.width) {
                    path.set(row, col, 'X');
                    break;
                }
                if (map.get(row, col + 1) == '#') {
                    d = 180;
                } else {
                    path.set(row, col, 'X');
                    col += 1;
                }
            },
            180 => {
                if (row + 1 == map.height) {
                    path.set(row, col, 'X');
                    break;
                }
                if (map.get(row + 1, col) == '#') {
                    d = 270;
                } else {
                    path.set(row, col, 'X');
                    row += 1;
                }
            },
            270 => {
                if (col == 0) {
                    path.set(row, col, 'X');
                    break;
                }
                if (map.get(row, col - 1) == '#') {
                    d = 0;
                } else {
                    path.set(row, col, 'X');
                    col -= 1;
                }
            },
            else => {
                return;
            },
        }
    }

    var x: u32 = 0;

    for (path.data) |c| {
        if (c == 'X') x += 1;
    }

    print("{d}", .{x});
}
