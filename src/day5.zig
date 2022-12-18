const std = @import("std");
const assert = std.debug.assert;
const util = @import("util.zig");

pub fn day5(allocator: std.mem.Allocator, input: []const u8) !void {
    const break_pos = std.mem.indexOfPos(u8, input, 0, "\n\n") orelse return error.InvalidInput;
    var stacks_input = input[0 .. break_pos - 1]; //remove last newline
    var inst_input = std.mem.tokenize(u8, input[break_pos..], "\n");
    std.debug.print("{s}\n", .{stacks_input});

    var b_lines = std.mem.splitBackwards(u8, stacks_input, "\n");
    var pos_list = std.ArrayList(usize).init(allocator);
    defer pos_list.deinit();
    var stack_pos_line = b_lines.next().?; //overengineering, yay! get positions from last line of stack diagram
    for (stack_pos_line) |c, i| {
        switch (c) {
            '0'...'9' => pos_list.append(i) catch unreachable,
            else => {},
        }
    }

    const stack_poses = try pos_list.toOwnedSlice();
    defer allocator.free(stack_poses);

    var stacks = try allocator.alloc(Stack, stack_poses.len);
    defer allocator.free(stacks);

    for (stacks) |_, i| {
        stacks[i] = Stack.init(allocator);
        try stacks[i].ensureTotalCapacity(2 * util.count(stacks_input, '\n'));
    }

    while (b_lines.next()) |line| {
        if (line.len == 0) continue;
        for (stack_poses) |pos, i| {
            if (line[pos] >= 'A' and line[pos] <= 'Z') try stacks[i].append(line[pos]);
        }
    }

    //swap this for mover9000 for part 1
    try mover9001(stacks, &inst_input);

    std.debug.print("output: ", .{});
    for (stacks) |*stack| {
        std.debug.print("{c}", .{stack.pop()});
    }
    std.debug.print("\n", .{});
}

fn mover9000(stacks: []Stack, inst_input: *std.mem.TokenIterator(u8)) !void {
    while (inst_input.next()) |in| {
        const inst = MoveInst.init(in);
        var i: usize = 0;
        while (i < inst.count) : (i += 1) {
            const c = stacks[inst.from].pop();
            try stacks[inst.to].append(c);
        }
    }
}

fn mover9001(stacks: []Stack, inst_input: *std.mem.TokenIterator(u8)) !void {
    // maintain order of boxes that get removed
    while (inst_input.next()) |in| {
        const inst = MoveInst.init(in);
        const from = stacks[inst.from].items;
        try stacks[inst.to].appendSlice(from[from.len - inst.count ..]);
        var i: usize = 0;
        while (i < inst.count) : (i += 1) _ = stacks[inst.from].pop();
    }
}

const Stack = std.ArrayList(u8);

const MoveInst = struct {
    count: usize,
    from: usize,
    to: usize,
    fn init(input: []const u8) MoveInst {
        var line = std.mem.tokenize(u8, input, " ");
        _ = line.next().?;
        const count = line.next().?;
        _ = line.next();
        const from = line.next().?;
        _ = line.next();
        const to = line.next().?;
        return .{
            .count = std.fmt.parseInt(u8, count, 10) catch unreachable,
            .from = (std.fmt.parseInt(u8, from, 10) catch unreachable) - 1,
            .to = (std.fmt.parseInt(u8, to, 10) catch unreachable) - 1,
        };
    }
};
