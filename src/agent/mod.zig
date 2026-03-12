const std = @import("std");

const Planner = @import("planner.zig").Planner;
const Executor = @import("executor.zig").Executor;
const ToolRegistry = @import("../tools/registry.zig").ToolRegistry;

pub const Agent = struct {
    allocator: std.mem.Allocator,
    planner: Planner,
    executor: Executor,
    config: ?Config,

    pub const Config = struct {
        base_url: []const u8,
        api_key: ?[]const u8,
        model_name: []const u8,
    };

    pub fn init(allocator: std.mem.Allocator) !Agent {
        return Agent{
            .allocator = allocator,
            .planner = Planner.init(allocator),
            .executor = try Executor.init(allocator),
            .config = null,
        };
    }

    pub fn deinit(self: *Agent) void {
        self.planner.deinit();
        self.executor.deinit();
        if (self.config) |*cfg| {
            self.allocator.free(cfg.base_url);
            if (cfg.api_key) |key| self.allocator.free(key);
            self.allocator.free(cfg.model_name);
        }
    }

    pub fn configureLlmConnection(self: *Agent, base_url: []const u8, api_key: ?[]const u8, model_name: ?[]const u8) !void {
        // Store config for later display
        if (self.config) |*cfg| {
            self.allocator.free(cfg.base_url);
            if (cfg.api_key) |key| self.allocator.free(key);
            self.allocator.free(cfg.model_name);
        }

        self.config = Config{
            .base_url = try self.allocator.dupe(u8, base_url),
            .api_key = if (api_key) |key| try self.allocator.dupe(u8, key) else null,
            .model_name = try self.allocator.dupe(u8, model_name orelse "kimi-k2.5"),
        };

        try self.planner.setConnectionConfig(base_url, api_key, model_name);
    }

    pub fn printConfig(self: *Agent) !void {
        const stdout_file = std.fs.File.stdout();

        try stdout_file.writeAll("\n=== Current Configuration ===\n");

        if (self.config) |cfg| {
            try stdout_file.writeAll("LLM Provider: OpenAI-compatible API\n");
            try stdout_file.writeAll("Base URL: ");
            try stdout_file.writeAll(cfg.base_url);
            try stdout_file.writeAll("\n");

            try stdout_file.writeAll("API Key: ");
            if (cfg.api_key) |key| {
                // Mask the API key for security
                if (key.len > 8) {
                    try stdout_file.writeAll(key[0..4]);
                    try stdout_file.writeAll("...");
                    try stdout_file.writeAll(key[key.len - 4 ..]);
                } else {
                    try stdout_file.writeAll("(set)");
                }
            } else {
                try stdout_file.writeAll("(not set)");
            }
            try stdout_file.writeAll("\n");

            try stdout_file.writeAll("Model: ");
            try stdout_file.writeAll(cfg.model_name);
            try stdout_file.writeAll("\n");
        } else {
            try stdout_file.writeAll("No configuration loaded.\n");
        }

        try stdout_file.writeAll("=============================\n\n");
    }

    pub fn runPrompt(self: *Agent, prompt: []const u8) !void {
        const plan = try self.planner.plan(prompt);
        defer self.allocator.free(plan.tool);

        try self.executor.execute(plan.tool, plan.argument);
    }
};
