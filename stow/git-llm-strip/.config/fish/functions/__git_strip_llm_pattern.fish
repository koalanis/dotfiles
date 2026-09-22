function __git_strip_llm_pattern --description 'ERE matching LLM attribution lines in commit messages'
    set -l tools 'claude|anthropic|chatgpt|openai|gpt|copilot|gemini|cursor|aider|devin|codex|cline|windsurf|sweep'
    echo '^[[:space:]]*(co-authored|assisted|generated|co-developed)-by:.*('$tools')|generated (with|by).*('$tools')|^[[:space:]]*🤖'
end
