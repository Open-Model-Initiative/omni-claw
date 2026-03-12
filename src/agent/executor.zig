const std = @import("std");
const ToolRegistry = @import("../tools/registry.zig").ToolRegistry;
const createDefaultRegistry = @import("../tools/registry.zig").createDefaultRegistry;

pub const Executor = struct {
    allocator: std.mem.Allocator,
    registry: ToolRegistry,

    pub fn init(allocator: std.mem.Allocator) !Executor {
        return Executor{
            .allocator = allocator,
            .registry = try createDefaultRegistry(allocator),
        };
    }

    pub fn deinit(self: *Executor) void {
        self.registry.deinit();
    }

    pub fn execute(self: *Executor, tool: []const u8, argument: []const u8) !void {
        // Look up the tool in the registry
        const tool_def = self.registry.get(tool) orelse {
            std.debug.print("Error: Unknown tool '{s}'\n", .{tool});
            std.debug.print("Available tools: exec, finish\n", .{});
            return error.UnknownTool;
        };

        // Execute the tool
        try tool_def.executor(self.allocator, argument);
    }

    /// Get the tool registry (for inspection)
    pub fn getRegistry(self: *Executor) *ToolRegistry {
        return &self.registry;
    }
};
