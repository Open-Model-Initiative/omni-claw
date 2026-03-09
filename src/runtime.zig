
const std = @import("std");

const Agent = @import("agent/agent.zig").Agent;
const Repl = @import("transport/repl.zig");

pub const Runtime = struct {

    allocator: std.mem.Allocator,
    agent: Agent,

    pub fn init(allocator: std.mem.Allocator) !Runtime {

        return Runtime{
            .allocator = allocator,
            .agent = try Agent.init(allocator),
        };
    }

    pub fn deinit(self: *Runtime) void {
        self.agent.deinit();
    }

    pub fn start(self: *Runtime) !void {

        std.debug.print("OmniClaw-Zig-RLM runtime started\n", .{});

        try Repl.run(&self.agent);
    }
};
