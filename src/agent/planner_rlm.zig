const std = @import("std");

pub const Plan = struct {
    tool: []const u8,
};

pub const Planner = struct {

    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Planner {
        return .{ .allocator = allocator };
    }

    pub fn plan(self: *Planner, prompt: []const u8) !Plan {

        _ = self;

        // TODO: connect to Omni-RLM server here
        // For now we use a simple fallback planner

        if (std.mem.indexOf(u8, prompt, "search") != null)
            return Plan{ .tool = "web_search" };

        return Plan{ .tool = "echo" };
    }
};