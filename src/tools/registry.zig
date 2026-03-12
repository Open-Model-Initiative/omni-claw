const std = @import("std");

/// Tool definition structure
pub const Tool = struct {
    name: []const u8,
    description: []const u8,
    executor: ToolExecutor,
};

/// Tool executor function type
pub const ToolExecutor = *const fn (allocator: std.mem.Allocator, argument: []const u8) anyerror!void;

/// Tool registry - stores all available tools
pub const ToolRegistry = struct {
    allocator: std.mem.Allocator,
    tools: std.StringHashMap(Tool),

    pub fn init(allocator: std.mem.Allocator) ToolRegistry {
        return .{
            .allocator = allocator,
            .tools = std.StringHashMap(Tool).init(allocator),
        };
    }

    pub fn deinit(self: *ToolRegistry) void {
        self.tools.deinit();
    }

    /// Register a new tool
    pub fn register(self: *ToolRegistry, tool: Tool) !void {
        try self.tools.put(tool.name, tool);
    }

    /// Get a tool by name
    pub fn get(self: *ToolRegistry, name: []const u8) ?Tool {
        return self.tools.get(name);
    }

    /// Check if a tool exists
    pub fn has(self: *ToolRegistry, name: []const u8) bool {
        return self.tools.contains(name);
    }

    /// Get list of all tool names (caller must free the returned slice)
    pub fn listToolNames(self: *ToolRegistry, buffer: *std.ArrayList(u8)) !void {
        var it = self.tools.keyIterator();
        var first = true;
        while (it.next()) |key| {
            if (!first) {
                try buffer.appendSlice(", ");
            }
            try buffer.appendSlice(key.*);
            first = false;
        }
    }
};

/// Default tool registry with all built-in tools
pub fn createDefaultRegistry(allocator: std.mem.Allocator) !ToolRegistry {
    var registry = ToolRegistry.init(allocator);
    errdefer registry.deinit();

    // Register exec tool for bash execution
    try registry.register(.{
        .name = "exec",
        .description = "Execute bash commands in the current environment",
        .executor = execBash,
    });

    // Register finish tool for providing final answers
    try registry.register(.{
        .name = "finish",
        .description = "Provide final answer and complete the task",
        .executor = finishTask,
    });

    return registry;
}

/// Execute bash command
fn execBash(allocator: std.mem.Allocator, argument: []const u8) !void {
    if (argument.len == 0) {
        std.debug.print("Error: No command provided\n", .{});
        return;
    }

    std.debug.print("$ {s}\n", .{argument});

    var child = std.process.Child.init(
        &.{ "bash", "-c", argument },
        allocator,
    );
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;

    const term = try child.spawnAndWait();

    switch (term) {
        .Exited => |code| {
            if (code != 0) {
                std.debug.print("\n[Exit code: {d}]\n", .{code});
            }
        },
        .Signal => |sig| {
            std.debug.print("\n[Terminated by signal: {d}]\n", .{sig});
        },
        else => {
            std.debug.print("\n[Process terminated abnormally]\n", .{});
        },
    }
}

/// Finish task with final response
fn finishTask(allocator: std.mem.Allocator, argument: []const u8) !void {
    _ = allocator;

    // Print the final response
    std.debug.print("\n{s}\n", .{argument});
}
