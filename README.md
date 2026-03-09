
# OmniClaw-Zig-RLM

OmniClaw-Zig-RLM is an experimental Zig AI agent runtime that integrates
with Omni-RLM from the Open Model Initiative.

Omni-RLM:
https://github.com/Open-Model-Initiative/Omni-RLM/

This project demonstrates how OmniClaw can use Omni-RLM as its reasoning
and planning backend.

## Features

- Omni-RLM reasoning engine integration (HTTP API)
- WASM sandbox tool execution
- Vector memory scaffold
- SQLite persistence scaffold
- Plugin tool architecture
- CLI REPL interface
- HTTP API scaffolding

## Architecture

User Prompt
    ↓
Omni-RLM Planner
    ↓
Tool Selection
    ↓
WASM Tool Execution
    ↓
Memory Storage

## Running

Requirements

- Zig
- Omni-RLM server running
- SQLite
- Wasmtime

Build

    zig build

Run

    ./zig-out/bin/omniclaw

Example

    > search zig memory management
