const std = @import("std");
const util = @import("util.zig");
const sr = @import("sliderule");

const Pos = sr.Vec2(isize);
const PosMap = std.AutoArrayHashMap(Pos, void);

pub fn day9(allocator: std.mem.Allocator, input: []const u8) !void {
    var lines = std.mem.tokenize(u8, input, "\n");
    var head: Pos = .{};
    var tail: Pos = .{};
    var h_posns = PosMap.init(allocator);
    defer h_posns.deinit();
    try h_posns.put(tail, {});
    var t_posns = PosMap.init(allocator);
    defer t_posns.deinit();
    try t_posns.put(tail, {});

    const h = 5;
    const w = 6;
    var map = try allocator.alloc(u8, w * h);
    defer allocator.free(map);

    std.mem.set(u8, map, '.');

    while (lines.next()) |line| {
        const inst = parseInst(line);
        std.debug.print("{} {}\n", .{ inst.dir, inst.dist });

        var moved: usize = 0;
        while (moved < inst.dist) {
            switch (inst.dir) {
                .right => {
                    head.x += 1;
                    var dx = try std.math.absInt(tail.x - head.x);
                    if (dx > 1) {
                        if (tail.y == head.y) {
                            tail.x += if (head.x > tail.x) 1 else -1;
                        } else if (tail.x == head.x) {
                            tail.y += if (head.y > tail.y) 1 else -1;
                        } else {
                            tail.x += if (head.x > tail.x) 1 else -1;
                            tail.y += if (head.y > tail.y) 1 else -1;
                        }
                    }
                },
                .left => {
                    head.x -= 1;
                    var dx = try std.math.absInt(tail.x - head.x);
                    if (dx > 1) {
                        if (tail.y == head.y) {
                            tail.x += if (head.x > tail.x) 1 else -1;
                        } else if (tail.x == head.x) {
                            tail.y += if (head.y > tail.y) 1 else -1;
                        } else {
                            tail.x += if (head.x > tail.x) 1 else -1;
                            tail.y += if (head.y > tail.y) 1 else -1;
                        }
                    }
                },
                .up => {
                    head.y -= 1;
                    const dy = try std.math.absInt(tail.y - head.y);
                    if (dy > 1) {
                        if (tail.y == head.y) {
                            tail.x += if (head.x > tail.x) 1 else -1;
                        } else if (tail.x == head.x) {
                            tail.y += if (head.y > tail.y) 1 else -1;
                        } else {
                            tail.x += if (head.x > tail.x) 1 else -1;
                            tail.y += if (head.y > tail.y) 1 else -1;
                        }
                    }
                },
                .down => {
                    head.y += 1;
                    const dy = try std.math.absInt(tail.y - head.y);
                    if (dy > 1) {
                        if (tail.y == head.y) {
                            tail.x += if (head.x > tail.x) 1 else -1;
                        } else if (tail.x == head.x) {
                            tail.y += if (head.y > tail.y) 1 else -1;
                        } else {
                            tail.x += if (head.x > tail.x) 1 else -1;
                            tail.y += if (head.y > tail.y) 1 else -1;
                        }
                    }
                },
            }
            std.debug.print("{}\n", .{head});
            try h_posns.put(head, {});
            try t_posns.put(tail, {});
            moved += 1;
        }
        std.debug.print("h posns:\n", .{});
        try draw(map, h_posns, 'H');
        std.debug.print("t posns:\n", .{});
        try draw(map, t_posns, 'T');
    }
    std.debug.print("tail poses: {}\n", .{t_posns.count()});
}

fn draw(map: []u8, posns: PosMap, char: u8) !void {
    std.mem.set(u8, map, '.');
    const h = 5;
    const w = 6;

    var iter = posns.iterator();
    while (iter.next()) |entry| {
        const pos = entry.key_ptr.*;
        map[@intCast(usize, try std.math.absInt(pos.y * w + pos.x))] = char;
    }

    {
        var x: usize = 0;
        var y: usize = h - 1;
        while (y > 0) : (y -= 1) {
            while (x < w) : (x += 1) {
                std.debug.print("{c}", .{map[y * w + x]});
            }
            std.debug.print("\n", .{});
            x = 0;
        }
        while (x < w) : (x += 1) {
            std.debug.print("{c}", .{map[y * w + x]});
        }
        std.debug.print("\n", .{});
    }
}

const Dir = enum { up, left, down, right };
const Inst = struct { dir: Dir, dist: usize };

fn parseInst(line: []const u8) Inst {
    var insts = std.mem.tokenize(u8, line, " ");
    const dir_str = insts.next().?;

    return .{
        .dist = switch (insts.next().?[0]) {
            '0'...'9' => |c| c - '0',
            else => unreachable,
        },
        .dir = switch (dir_str[0]) {
            'U' => .up,
            'D' => .down,
            'L' => .left,
            'R' => .right,
            else => unreachable,
        },
    };
}
