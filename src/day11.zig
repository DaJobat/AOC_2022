const std = @import("std");
const util = @import("util.zig");
const mem = std.mem;
const assert = std.debug.assert;

pub fn day11(allocator: std.mem.Allocator, input: []const u8) !void {
    const PART_ONE = false;

    var lines = mem.tokenize(u8, input, "\n");
    var cmds = std.ArrayList(Cmd).init(allocator);
    defer cmds.deinit();

    while (lines.next()) |line| {
        var cmd_it = mem.tokenize(u8, line, ":");
        try cmds.append(try Cmd.init(allocator, cmd_it.next().?, cmd_it.rest()));
    }
    var commands = try cmds.toOwnedSlice();
    defer allocator.free(commands);

    var monkey_list = std.ArrayList(Monkey).init(allocator);
    defer monkey_list.deinit();
    {
        var i: usize = 0;
        while (i < commands.len) : (i += 1) {
            var cmd = commands[i];
            assert(cmd.monkey == monkey_list.items.len);
            i += 1;
            const items = commands[i].items;
            i += 1;
            const op = commands[i].operation;
            i += 1;
            const div_by = commands[i].test_c;
            i += 1;
            assert(commands[i].cond.cond);
            const true_idx = commands[i].cond.idx;
            i += 1;
            assert(!commands[i].cond.cond);
            const false_idx = commands[i].cond.idx;
            try monkey_list.append(.{
                .items = items,
                .op = op,
                .div_by = div_by,
                .true_idx = true_idx,
                .false_idx = false_idx,
            });
        }
    }

    var monkeys = try monkey_list.toOwnedSlice();
    defer allocator.free(monkeys);
    var counts = try allocator.alloc(usize, monkeys.len);
    defer allocator.free(counts);

    std.mem.set(usize, counts, 0);

    const gcd = blk: {
        var acc: i64 = 1;
        for (monkeys) |monkey| {
            acc *= monkey.div_by;
        }

        break :blk acc;
    };
    std.debug.print("gcd {}\n", .{gcd});

    {
        const num_rounds = if (PART_ONE) 20 else 10000;
        var i: usize = 0;
        while (i < num_rounds) : (i += 1) {
            for (monkeys) |*monkey, j| {
                //std.debug.print("Monkey {}\n", .{j});
                var worry_level: i64 = 0;
                for (monkey.items.items) |item| {
                    worry_level = item;
                    //std.debug.print("monkey inspects item {}\t", .{worry_level});
                    switch (monkey.op.op) {
                        .add => {
                            worry_level += switch (monkey.op.val) {
                                .value => |v| v,
                                .old => worry_level,
                            };
                            //std.debug.print("add to {}\n", .{worry_level});
                        },
                        .mul => {
                            worry_level *= switch (monkey.op.val) {
                                .value => |v| v,
                                .old => worry_level,
                            };
                            //std.debug.print("mul to {}\n", .{worry_level});
                        },
                    }
                    if (PART_ONE) worry_level = @divFloor(worry_level, 3);
                    worry_level = @mod(worry_level, gcd);

                    if (@mod(worry_level, monkey.div_by) == 0) {
                        //std.debug.print("{} divs by  {}, throw to {}\n", .{ worry_level, monkey.div_by, monkey.true_idx });
                        try monkeys[monkey.true_idx].items.append(worry_level);
                    } else {
                        //std.debug.print("{} doesn't div by  {}, throw to {}\n", .{ worry_level, monkey.div_by, monkey.false_idx });
                        try monkeys[monkey.false_idx].items.append(worry_level);
                    }
                    counts[j] += 1;
                }
                while (monkey.items.popOrNull() != null) {}
            }
        }
    }

    std.sort.sort(usize, counts, {}, std.sort.desc(usize));
    std.debug.print("result: {}\n", .{counts[0] * counts[1]});
}

const Monkey = struct {
    items: std.ArrayList(i64),
    op: Cmd.Operation,
    div_by: i64,
    true_idx: usize,
    false_idx: usize,
};

const CmdEnum = enum { monkey, items, operation, test_c, cond };

const CmdMap = std.ComptimeStringMap(CmdEnum, .{ .{ "Monkey", .monkey }, .{ "Starting", .items }, .{ "Operation", .operation }, .{ "Test", .test_c }, .{ "If", .cond } });

const Cmd = union(CmdEnum) {
    monkey: usize,
    items: std.ArrayList(i64),
    operation: Operation,
    test_c: i64,
    cond: Condition,

    fn init(allocator: std.mem.Allocator, type_str: []const u8, rest: []const u8) !Cmd {
        var iter = mem.tokenize(u8, type_str, " ");
        const ts = iter.next().?;
        const cmd_type = CmdMap.get(ts) orelse return error.InvalidTypeStr;
        return switch (cmd_type) {
            .monkey => Cmd{ .monkey = try std.fmt.parseInt(usize, iter.next().?, 10) },
            .items => blk: {
                var list = std.ArrayList(i64).init(allocator);
                var item_it = mem.tokenize(u8, rest, ", ");
                while (item_it.next()) |item| {
                    try list.append(try std.fmt.parseInt(i64, item, 10));
                }
                break :blk Cmd{ .items = list };
            },
            .operation => Cmd{ .operation = try Operation.init(allocator, rest) },
            .test_c => blk: {
                var args = try util.tokensToSlice(u8, allocator, rest, " ");
                defer allocator.free(args);
                break :blk Cmd{ .test_c = try std.fmt.parseInt(i64, args[2], 10) };
            },
            .cond => blk: {
                var c = try util.tokensToSlice(u8, allocator, rest, " ");
                defer allocator.free(c);

                break :blk Cmd{ .cond = .{ .cond = mem.eql(u8, "true", iter.next().?), .idx = try std.fmt.parseInt(usize, c[3], 10) } };
            },
        };
    }

    const Operation = struct {
        const Val = union(enum) { value: i64, old: void };
        op: enum { add, mul },
        val: Val,
        fn init(allocator: std.mem.Allocator, str: []const u8) !Operation {
            var args = try util.tokensToSlice(u8, allocator, str, " ");
            defer allocator.free(args);
            assert(args.len == 5);
            var val: Val = undefined;
            if (std.fmt.parseInt(i64, args[4], 10)) |number| {
                val = Val{ .value = number };
            } else |_| {
                val = Val{ .old = {} };
            }
            return .{
                .op = switch (args[3][0]) {
                    '*' => .mul,
                    '+' => .add,
                    else => unreachable,
                },
                .val = val,
            };
        }
    };
    const Condition = struct { cond: bool, idx: usize };
};
