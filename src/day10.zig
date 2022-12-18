const std = @import("std");
const assert = std.debug.assert;
const util = @import("util.zig");

const InstEnum = enum { noop, addx };
const Instruction = union(InstEnum) {
    noop: void,
    addx: isize,
};

const inst_times = std.EnumArray(InstEnum, usize).init(.{ .noop = 1, .addx = 2 });

const insts = std.ComptimeStringMap(InstEnum, .{ .{ "noop", .noop }, .{ "addx", .addx } });
const State = struct {
    x_reg: isize,
    inst: Instruction,
};

pub fn day10(ally: std.mem.Allocator, input: []const u8) !void {
    var states = std.ArrayList(State).init(ally);
    defer states.deinit();
    var instruction_list = std.ArrayList(Instruction).init(ally);
    defer instruction_list.deinit();

    var lines = std.mem.tokenize(u8, input, "\n");
    while (lines.next()) |line| {
        var tok = std.mem.tokenize(u8, line, " ");
        try instruction_list.append(switch (insts.get(tok.next().?).?) {
            .addx => Instruction{ .addx = try std.fmt.parseInt(isize, tok.next().?, 10) },
            .noop => Instruction{ .noop = {} },
        });
    }

    const instructions = try instruction_list.toOwnedSlice();
    defer ally.free(instructions);

    var x_reg: isize = 1;
    for (instructions) |inst| {
        var i: usize = 0;
        while (i < inst_times.get(inst)) : (i += 1) {
            try states.append(.{ .x_reg = x_reg, .inst = inst });
            std.debug.print("{} {}\n", .{ states.items.len, states.items[states.items.len - 1] });
        }

        x_reg += switch (inst) {
            .addx => |val| val,
            else => 0,
        };
    }

    var cycles = &[_]usize{ 20, 60, 100, 140, 180, 220 };

    var total: isize = 0;
    for (cycles) |c| {
        const state = states.items[c - 1];
        const amt = state.x_reg * @intCast(isize, c + 1);
        std.debug.print("{} {}\n", .{ state, amt });
        total += amt;
    }

    std.debug.print("total: {}\n", .{total});

    const w = 40;

    var out = std.io.getStdOut().writer();
    for (states.items) |state, i| {
        const mod = @mod(i, w);
        if (mod == 0) {
            try out.writeByte('\n');
        }
        try out.writeByte(if (state.x_reg == mod or state.x_reg - 1 == mod or state.x_reg + 1 == mod) '#' else '.');
    }
    try out.writeByte('\n');
}
