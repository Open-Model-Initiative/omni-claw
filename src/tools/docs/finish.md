# finish

**Category:** Control  
**Description:** Provide a final answer to the user and complete the current task without executing any system commands.

## Overview

The `finish` tool is used when you have determined that no system command execution is needed, and you can provide a direct answer to the user's request. This tool signals the completion of the task and presents your final response to the user.

Use this tool when:
- The user's question can be answered directly without system interaction
- You have gathered sufficient information to provide a complete answer
- The task is conversational or informational in nature
- No file operations or system commands are required

## When to Use finish vs exec

**Use `finish` when:**
- Answering general knowledge questions
- Providing explanations or analysis
- Conversational responses (greetings, goodbyes, thanks)
- Clarifying questions or providing help text
- Summarizing information already obtained

**Use `exec` when:**
- User needs to see file contents or directory listings
- System information is required (disk usage, processes, etc.)
- Files need to be created, modified, or searched
- External programs need to be run
- Network operations are needed

## Usage

```json
{
  "tool": "finish",
  "argument": "Your final response to the user"
}
```

## Examples

**General knowledge question:**
```json
{
  "tool": "finish",
  "argument": "The capital of France is Paris. It is located in the north-central part of the country along the Seine River."
}
```

**Explanation:**
```json
{
  "tool": "finish",
  "argument": "To solve this equation: 2x + 4 = 10\n1. Subtract 4 from both sides: 2x = 6\n2. Divide by 2: x = 3"
}
```

**Conversation:**
```json
{
  "tool": "finish",
  "argument": "Hello! I'm Omni-Claw, your AI assistant. How can I help you today?"
}
```

**Task completion summary:**
```json
{
  "tool": "finish",
  "argument": "I've completed the file search. Found 3 files matching 'test' in the current directory:\n- test.txt\n- test_main.py\n- testing.sh"
}
```

## Best Practices

1. **Be Complete**: Provide a comprehensive answer that fully addresses the user's request
2. **Be Clear**: Format your response for readability (use line breaks, bullet points, etc.)
3. **Be Accurate**: Only state facts you are confident about
4. **Be Concise**: Don't include unnecessary information, but don't be too brief either
5. **Context Aware**: Reference any previous commands or information if relevant

## Response Format

The argument should be a plain text string containing your complete response. You can use:
- Plain text paragraphs
- Line breaks (`\n`) for formatting
- Bullet points or numbered lists
- Code blocks (using backticks)
- Any other text formatting that improves readability

## Notes

- The finish tool does NOT execute any system commands
- The argument is displayed directly to the user as your response
- Use this for the final answer after a series of exec operations
- This tool always completes the current task and returns to prompt
