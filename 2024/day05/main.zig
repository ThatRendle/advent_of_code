const std = @import("std");
const print = std.debug.print;
const allocator = @import("gpa.zig").allocator;
const Rule = @import("rule.zig").Rule;

const input = @embedFile("input.txt");

pub fn main() !void {
    print("Part One: {d}\n\n", .{try part_one()});
    print("Part Two: {d}\n\n", .{try part_two()});
}

fn part_one() !usize {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var total: usize = 0;
    const rules = try read_rules(&lines);

    line_loop: while (lines.next()) |line| {
        const pages = try parse_pages(line);
        for (rules) |rule| {
            if (!rule.run(pages)) continue :line_loop;
        }
        const middle = ((pages.len - 1) / 2);
        total += pages[middle];
    }

    return total;
}

fn part_two() !usize {
    var lines = std.mem.splitScalar(u8, input, '\n');
    var total: usize = 0;
    const rules = try read_rules(&lines);

    while (lines.next()) |line| {
        const pages = try parse_pages(line);
        var ok = true;
        for (rules) |rule| {
            ok = rule.run(pages) and ok;
        }
        if (ok) continue;
        while (true) {
            var fixed = false;
            for (rules) |rule| {
                fixed = rule.fix(pages) or fixed;
            }
            if (!fixed) break;
        }
        const middle = ((pages.len - 1) / 2);
        total += pages[middle];
    }

    return total;
}

fn read_rules(lines: *std.mem.SplitIterator(u8, .scalar)) ![]Rule {
    var list = std.ArrayList(Rule).init(allocator);
    while (lines.next()) |line| {
        if (line.len == 0) {
            return try allocator.dupe(Rule, list.items);
        }
        const pipe_index = std.mem.indexOfScalar(u8, line, '|').?;

        const l = try std.fmt.parseInt(usize, line[0..pipe_index], 10);
        const r = try std.fmt.parseInt(usize, line[pipe_index + 1 ..], 10);

        const rule = Rule.create(l, r);

        try list.append(rule);
    }

    return try allocator.dupe(Rule, list.items);
}

fn parse_pages(line: []const u8) ![]usize {
    var tokens = std.mem.splitScalar(u8, line, ',');

    var list = std.ArrayList(usize).init(allocator);
    defer list.deinit();

    while (tokens.next()) |token| {
        const n = try std.fmt.parseInt(usize, token, 10);
        try list.append(n);
    }

    return try allocator.dupe(usize, list.items);
}
