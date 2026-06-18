# CLAUDE.MD - Critical Instructions for Claude AI Assistant

## CRITICAL WORKFLOW REQUIREMENT: Memory MCP Usage

**MANDATORY: You MUST follow this workflow for EVERY task without exception:**

### 1. **BEFORE starting ANY task:**
   - **ALWAYS** use Memory MCP FIRST via `mcp__mcphub__call_tool` with toolName: `memory-search_nodes` and arguments: `{"query": "search terms here"}`
   - Search for relevant information in multiple languages (English, Japanese, Vietnamese)
   - Look for past solutions, known issues, and previous approaches
   - **NEVER use `mcp__mcphub__search_tools` before checking Memory MCP**
   - **This is NOT optional** - ensures you don't miss important context from previous conversations

### 2. **AFTER completing ANY task:**
   - **ALWAYS** use `memory-create_entities` or `memory-add_observations` to save what was learned
   - **CRITICAL FAILURE POINT:** Not saving to memory after ANY task completion is a CRITICAL ERROR
   - **SAVE EVERYTHING RULE - You MUST save to memory:**
     - ANY information provided to the user (answers, instructions, explanations)
     - ANY discovered information (documentation, configurations, procedures)
     - ANY problem solutions (bugs, errors, workarounds, fixes)
     - ANY learned processes (workflows, commands, best practices)
     - ANY technical details (API endpoints, database schemas, system architectures)
     - ANY project-specific knowledge (naming conventions, deployment processes, team practices)
     - ANY tool usage patterns (which MCP tools work, parameters that succeed)
     - ANY user preferences or requirements mentioned
     - ANY contextual information that could be useful later
   - **DEFAULT BEHAVIOR:** When in doubt, SAVE IT TO MEMORY
   - Include comprehensive details:
     - Complete step-by-step procedures
     - Full command sequences with parameters
     - Exact error messages and their solutions
     - Configuration file paths and contents
     - Tool names and successful parameter formats
     - Links to documentation sources
     - Multi-language translations when applicable
   - Tag information with: `#summary #learned #notice #project #task #date` plus specific tags
   - **This is NOT optional** - builds knowledge base for future tasks
   - **CRITICAL REMINDER:** If you provide ANY information to the user but don't save it to memory, you have FAILED the task
   - **SAVE AGGRESSIVELY:** It's better to save too much than too little

### 3. **Why this is CRITICAL:**
   - ✅ Maintains continuity across all conversations
   - ✅ Prevents repeating the same mistakes
   - ✅ Builds a comprehensive knowledge base over time
   - ✅ Ensures efficient problem-solving by leveraging past experiences
   - ❌ Skipping this leads to lost context and repeated errors

---

## MCP Server Usage Requirements

**IMPORTANT: Maximize use of ALL available MCP servers:**

**MULTI-LANGUAGE SUPPORT: All MCP server interactions must support Japanese, English, and Vietnamese. Search queries, documentation requests, and content processing should work seamlessly across all three languages.**

**CRITICAL WORKFLOW ORDER:**
1. **ALWAYS start with Memory MCP search FIRST** using `mcp__mcphub__call_tool` with toolName: `memory-search_nodes`
2. **Then use other MCP servers** like ESA, VectorCode, etc. as needed
3. **NEVER use `mcp__mcphub__search_tools` as the first step** - always check memory first

### Available MCP Servers and Tools:

#### 1. **VectorCode MCP Server** (`mcp__vectorcode-mcp-server`)
- **Purpose:** Code search and understanding using vector embeddings
- **Key Tools:**
  - `ls`: List indexed projects available for querying
  - `query`: Search codebase using semantic search with multiple keywords
  - `vectorise`: Add files to the embedding database
  - `files_rm`: Remove files from embedding database
  - `files_ls`: List files that have been indexed
- **Best Practices:**
  - Use multiple orthogonal keywords for better search results
  - Increase file count if initial results don't contain needed context
  - Always run `ls` first to see available indexed projects

#### 2. **IDE MCP Server** (`mcp__ide`)
- **Purpose:** Integration with IDE for diagnostics
- **Key Tools:**
  - `getDiagnostics`: Get language diagnostics (errors, warnings) from the editor
- **Usage:** Check for code errors and warnings in open files

#### 3. **Memory MCP** (referenced but not shown in current tools)
- **Primary focus for knowledge persistence**
- **Used for storing and retrieving context from past conversations**

#### 4. **MCPhub MCP Server** (`mcp__mcphub`)
- **Purpose:** Access to a comprehensive collection of MCP tools across various domains
- **Key Tools:**
  - `search_tools`: Find relevant tools using natural language queries (STEP 1)
  - `call_tool`: Execute discovered tools with proper arguments (STEP 2)
- **Best Practices:**
  - Always use search_tools first to find the right tool
  - Use specific queries matching exact needs
  - Check tool inputSchema before calling tools

#### 5. **Memory MCP Server** (`memory`) - **PRIMARY PRIORITY**
- **Purpose:** Knowledge persistence and retrieval across conversations
- **CRITICAL:** This MUST be the FIRST MCP server used for every task
- **Usage:** Access via `mcp__mcphub__call_tool` with appropriate toolName
- **Key Tools:**
  - `memory-search_nodes`: Search knowledge graph for relevant information (ALWAYS USE FIRST)
  - `memory-create_entities`: Create new entities with observations
  - `memory-add_observations`: Add observations to existing entities
  - `memory-open_nodes`: Retrieve specific entities by name
  - `memory-read_graph`: Read entire knowledge graph
  - `memory-delete_observations`: Delete specific observations
- **Multi-language Search:** Always search in English, Japanese, and Vietnamese variants

#### 6. **CircleCI MCP Server** (`circleci`)
- **Purpose:** CI/CD pipeline management and monitoring
- **Key Tools:**
  - `circleci-list_followed_projects`: Get available projects
  - `circleci-get_latest_pipeline_status`: Check pipeline status
  - `circleci-run_pipeline`: Trigger new pipelines
  - `circleci-get_build_failure_logs`: Debug build failures
  - `circleci-get_job_test_results`: Check test results
  - `circleci-find_flaky_tests`: Identify unreliable tests
  - `circleci-run_rollback_pipeline`: Rollback deployments
  - `circleci-list_component_versions`: Manage component versions

#### 7. **Web Automation MCP Servers**
- **Playwright (`playwright`):** Advanced browser automation
  - `playwright-browser_install`: Install browser if needed
  - `playwright-browser_navigate`: Navigate to URLs
  - `playwright-browser_type`: Type text into elements
  - `playwright-browser_fill_form`: Fill multiple form fields
  - `playwright-browser_snapshot`: Capture accessibility snapshot
  - `playwright-browser_wait_for`: Wait for text/time
  - `playwright-browser_navigate_back`: Go back to previous page
  - `playwright-browser_close`: Close the page
- **Puppeteer (`puppeteer`):** Alternative browser automation
  - `puppeteer-puppeteer_navigate`: Navigate to URLs
  - `puppeteer-puppeteer_click`: Click elements
  - `puppeteer-puppeteer_fill`: Fill input fields
  - `puppeteer-puppeteer_select`: Select from dropdown
  - `puppeteer-puppeteer_hover`: Hover over elements
  - `puppeteer-puppeteer_evaluate`: Execute JavaScript
  - `puppeteer-puppeteer_screenshot`: Take screenshots

#### 8. **Development Support MCP Servers**
- **Context7 (`context7-mcp`):** Library documentation
  - `context7-mcp-resolve-library-id`: Find library IDs
  - `context7-mcp-get-library-docs`: Get up-to-date docs
- **Grep (`grep`):** Code search in GitHub repos
  - `grep-searchGitHub`: Find real-world code examples
- **Python Execution (`python-code-execution`)**
  - `python-code-execution-python_code_execution`: Execute Python code in sandbox
- **Diff (`diff-mcp`):** Text/data comparison
  - `diff-mcp-diff`: Compare and get readable diffs
- **Sequential Thinking (`sequentialthinking`, `sequential-thinking`):** Problem solving
  - `sequentialthinking-sequentialthinking`: Dynamic problem-solving with iterative thoughts
  - `sequential-thinking-sequentialthinking`: Alternative problem-solving tool

#### 9. **Data & Storage MCP Servers**
- **Postgres (`postgres`):** Database queries
  - `postgres-query`: Run read-only SQL queries
- **Fetch MCP Servers:** Web content retrieval
  - `fetch-mcp-fetch`: Fetch URLs and extract content as markdown
  - `web-fetch-fetch-web`: Fetch URLs and return content (images in ![]() format)
  - `web-fetch-read-image-url`: Read images from URLs for LLM processing
  - `fetcher-mcp-fetch_url`: Retrieve web page content from specified URL
  - `fetcher-mcp-fetch_urls`: Retrieve content from multiple URLs

#### 10. **AI & Media MCP Servers**
- **ElevenLabs (`elevenlabs-mcp`):** Voice AI
  - `elevenlabs-mcp-list_models`: Available voice models
  - `elevenlabs-mcp-list_agents`: Conversational AI agents
  - `elevenlabs-mcp-text_to_voice`: Text-to-speech generation
  - `elevenlabs-mcp-voice_clone`: Voice cloning
  - `elevenlabs-mcp-speech_to_speech`: Voice transformation
  - `elevenlabs-mcp-create_agent`: Create AI agents
  - `elevenlabs-mcp-search_voice_library`: Search ElevenLabs voice library
- **MiniMax (`minimax-mcp`):** Text-to-audio
  - `minimax-mcp-text_to_audio`: Convert text to audio
- **Nano Banana (`nano-banana-mcp`, `nano-banana-edit-mcp`):** AI Image Generation/Editing
  - `nano-banana-mcp-post_fal_ai_nano_banana`: Generate images from text
  - `nano-banana-edit-mcp-post_fal_ai_nano_banana_edit`: Edit images with AI
  - `nano-banana-mcp-get_fal_ai_nano_banana_requests`: Get request status
  - `nano-banana-mcp-put_fal_ai_nano_banana_requests_cancel`: Cancel requests

#### 11. **Project Management MCP Servers**
- **ESA (`esa`):** Air-Closet documentation system
  - `esa-read_esa_post`: Read documentation posts
  - `esa-read_esa_multiple_posts`: Read multiple posts
  - `esa-search_esa_posts`: Search documentation posts (MAIN SEARCH TOOL)
  - `esa-create_esa_post`: Create new posts
  - `esa-update_esa_post`: Update existing posts
  - `esa-delete_esa_post`: Delete posts
  - `esa-get_search_query_document`: Get search syntax documentation only
  - **CRITICAL:** Always use comprehensive multi-language synonym search in ONE query
  - **Usage:** Access via `mcp__mcphub__call_tool` with toolName: `esa-search_esa_posts`
  - **SEARCH STRATEGY:** Include ALL synonyms and related terms in multiple languages in a SINGLE query
  - **NEVER search step-by-step** - always combine all terms and languages into one comprehensive query
- **Backlog (`backlog`):** Project management
  - `backlog-get_space`: Get space information
  - `backlog-get_project`: Get specific project info
  - `backlog-get_project_list`: List all projects
  - `backlog-get_users`: List users in space
  - `backlog-get_priorities`: List priorities
  - `backlog-add_project`: Create new project
  - `backlog-count_issues`: Count issues with filters
  - `backlog-count_notifications`: Count notifications
  - `backlog-get_notifications`: List notifications
  - `backlog-reset_unread_notification_count`: Reset notification count
  - `backlog-get_myself`: Get authenticated user info

#### 12. **Utility MCP Servers**
- **Time (`time-mcp`):** Time-related utilities
  - `time-mcp-get_current_time`: Get current time in specific timezone
  - `time-mcp-convert_time`: Convert time between timezones
- **MCP Installer (`mcp-installer`):** MCP server management
  - `mcp-installer-install_local_mcp_server`: Install local MCP servers
  - `mcp-installer-install_repo_mcp_server`: Install MCP servers via npx/uvx
- **MCP Compass (`mcp-compass`):** MCP discovery
  - `mcp-compass-recommend-mcp-servers`: Find and recommend MCP servers

#### 13. **AWS & Cloud MCP Servers**
- **AWS Knowledge (`aws-knowledge-mcp-server`):** AWS documentation and guidance
  - `aws-knowledge-mcp-server-aws___search_documentation`: Search AWS documentation, blog, solutions, and guidance

### When to Use MCP Servers (MANDATORY ORDER):

**STEP 1 - ALWAYS FIRST:**
- **Memory MCP search:** Use `mcp__mcphub__call_tool` with toolName: `memory-search_nodes` for existing context
- **Multi-language search:** Query in English, Japanese, and Vietnamese variants

**STEP 2 - THEN OTHER MCP SERVERS:**
- **For Air-Closet tasks:** Use `mcp__mcphub__call_tool` with toolName: `esa-search_esa_posts` with comprehensive multi-language synonym search in ONE query
- **For code understanding:** Use VectorCode's query tool with relevant keywords
- **For error checking:** Use IDE MCP's getDiagnostics
- **For CI/CD tasks:** Use CircleCI MCP for pipeline management
- **For web automation:** Use Playwright or Puppeteer for browser tasks
- **For library documentation:** Use Context7 MCP for up-to-date docs
- **For code examples:** Use Grep MCP to search GitHub repositories
- **For database queries:** Use Postgres MCP for SQL operations
- **For web content:** Use Fetch MCP servers for retrieving and processing URLs
- **For voice/audio AI:** Use ElevenLabs or MiniMax MCP servers
- **For image generation/editing:** Use Nano Banana MCP servers
- **For project management:** Use Backlog MCP for project coordination
- **For complex problems:** Use Sequential Thinking MCP for structured analysis
- **For time operations:** Use Time MCP for timezone conversions
- **For AWS queries:** Use AWS Knowledge MCP for documentation
- **For Python execution:** Use Python Code Execution MCP for sandboxed code
- **For text comparison:** Use Diff MCP for readable diffs
- **For MCP discovery:** Use MCP Compass to find external MCP servers

**CRITICAL:** NEVER use `mcp__mcphub__search_tools` as the first step - always check memory first

---

## Node.js Version Management

**MANDATORY: Use `mise` for Node.js version management:**

- **NEVER use:** `npm`, `yarn`, or `node` commands directly
- **ALWAYS use:** `mise x -- node <command>`
- **Examples:**
  ```bash
  mise x -- node npm install       # Instead of: npm install
  mise x -- node yarn start         # Instead of: yarn start
  mise x -- node npm run build      # Instead of: npm run build
  ```
- **Why:** Ensures correct Node.js version for each project

---

## Task Documentation & Summary

**REQUIRED after EVERY significant task:**

1. **Create a comprehensive summary including:**
   - What was accomplished
   - What was learned
   - Important notices for next time
   - Any issues encountered and their solutions

2. **Save to Memory MCP with proper tags:**
   - Use tags: `#summary #learned #notice #project #task #date`
   - Include project name and date in the entity name
   - Be specific and detailed for future reference

---

## Code Writing Standards

### PRIORITY 1: Read and Match Existing Code Style

**MANDATORY: Before writing ANY code:**

1. **ALWAYS analyze the existing codebase first:**
   - Read surrounding code files in the same directory
   - Identify the coding patterns and conventions already in use
   - Check for existing similar functions/components to use as templates
   - Note the style preferences (formatting, naming, structure)

2. **COPY the existing style exactly:**
   - Match indentation (spaces vs tabs, number of spaces)
   - Follow naming conventions (camelCase, snake_case, etc.)
   - Use the same patterns (functional vs OOP, async/await vs promises)
   - Maintain consistency with existing code structure
   - Use the same libraries and utilities already in the project

3. **Style detection checklist:**
   - Language preference (TypeScript vs JavaScript)
   - Programming paradigm (functional, OOP, procedural)
   - Formatting style (brackets, semicolons, quotes)
   - Import/export patterns
   - Error handling approaches
   - Comment style and documentation format

### PRIORITY 2: Default Standards (Only if no existing code to reference)

**If starting a completely new project with no existing code:**

1. **TypeScript by default**
   - Write type-safe code with proper interfaces and types
   - Use strict type checking
   - Define clear type definitions

2. **Functional programming patterns by default:**
   - Use pure functions wherever possible
   - Prefer immutability (const over let/var)
   - Use map, filter, reduce instead of loops
   - Avoid side effects

**IMPORTANT:** These defaults are ONLY used when there's no existing code to reference. Always prioritize matching existing code style over these defaults.

---

## IMPORTANT REMINDERS

1. **These are NOT suggestions - they are REQUIREMENTS**
2. **Following these instructions is MANDATORY for every interaction**
3. **Skipping any of these steps should be considered a critical error**
4. **When in doubt, refer back to these instructions**

---

## Quick Checklist for Every Task

- [ ] **STEP 1:** Used `mcp__mcphub__call_tool` with `memory-search_nodes` to search Memory MCP FIRST
- [ ] Searched in all three languages (English, Japanese, Vietnamese)
- [ ] **STEP 2:** Used other appropriate MCP servers (ESA, VectorCode, etc.)
- [ ] For ESA searches: used `mcp__mcphub__call_tool` with `esa-search_esa_posts` in multiple languages
- [ ] **NEVER** used `mcp__mcphub__search_tools` as first step
- [ ] Used `mise x -- node` for Node.js commands
- [ ] Read existing code style before writing new code
- [ ] Matched existing code patterns and conventions
- [ ] Saved learnings to memory MCP after task
- [ ] Created comprehensive summary with proper tags

## Multi-Language Synonym Search Strategy

**CRITICAL: Always search with comprehensive synonyms in ONE query, not step-by-step**

**NEVER search with individual terms - always combine ALL relevant synonyms in multiple languages into ONE comprehensive query.**

---

## MCP Tool Parameters Reference

**CRITICAL: Always use exact parameter names to avoid MCP errors**

### Common Parameter Naming Issues and Fixes:

#### ESA MCP Tools:
- **esa-read_esa_post**: Use `postNumber` (NOT `number`)
- **esa-delete_esa_post**: Use `postNumber` (NOT `number`)
- **esa-update_esa_post**: Use `postNumber` (NOT `number`)
- **esa-read_esa_multiple_posts**: Use `postNumbers` (array of numbers)
- **esa-search_esa_posts**: Use `query` (NOT `q`)
- **esa-create_esa_post**: Required: `name`, Optional: `body_md`, `tags`, `category`, `wip`, `message`

#### Memory MCP Tools:
- **memory-search_nodes**: Use `query` (string) - Example: `{"query": "air-closet-api deployment"}`
- **memory-create_entities**: Use `entities` (array) - Example: `{"entities": [{"name": "Entity Name", "entityType": "Type", "observations": ["observation1", "observation2"]}]}`
- **memory-add_observations**: Use `observations` (array) - Example: `{"observations": [{"entityName": "Existing Entity", "contents": ["new observation1", "new observation2"]}]}`
- **memory-delete_observations**: Use `deletions` (array) - Example: `{"deletions": [{"entityName": "Entity Name", "observations": ["observation to delete"]}]}`
- **memory-open_nodes**: Use `names` (array) - Example: `{"names": ["Entity1", "Entity2"]}`
- **memory-create_relations**: Use `relations` (array) - Example: `{"relations": [{"from": "Entity1", "to": "Entity2", "relationType": "relates_to"}]}`
- **memory-read_graph**: No parameters - Example: `{}`
- **memory-delete_entities**: Use `entityNames` (array) - Example: `{"entityNames": ["Entity1", "Entity2"]}`

#### CircleCI MCP Tools:
- **circleci-get_build_failure_logs**: Use `params` object with `projectSlug`+`branch` OR `projectURL` OR `workspaceRoot`+`gitRemoteURL`+`branch`
- **circleci-get_job_test_results**: Use `params` object with same options as above plus optional `filterByTestsResult`
- **circleci-list_component_versions**: Use `params` object with `projectSlug` OR `projectID`, optional `orgID`, `environmentID`, `componentID`

#### VectorCode MCP Tools:
- **mcp__vectorcode-mcp-server__query**: Use `n_query`, `query_messages`, `project_root` (all required)
- **mcp__vectorcode-mcp-server__vectorise**: Use `paths`, `project_root` (both required)
- **mcp__vectorcode-mcp-server__files_rm**: Use `files`, `project_root` (both required)
- **mcp__vectorcode-mcp-server__files_ls**: Use `project_root` (required)

#### Backlog MCP Tools:
- **backlog-get_document**: Use `documentId` (NOT `id`)
- **backlog-get_documents**: Use `projectIds` (array, NOT `projectId`)
- **backlog-get_issues**: Multiple optional filters, use exact names like `projectId`, `issueTypeId`, etc.
- **backlog-count_issues**: Same parameter names as get_issues

#### Web Fetch Tools:
- **fetch-mcp-fetch**: Varies by provider
- **fetcher-mcp-fetch_url**: Use `url` (single URL)
- **fetcher-mcp-fetch_urls**: Use `urls` (array of URLs)
- **web-fetch-fetch-web**: Check specific provider documentation

#### Playwright/Puppeteer Tools:
- **playwright-browser_type**: Use `element`, `ref`, `text` (all required)
- **playwright-browser_evaluate**: Use `function` (required), optional `element`, `ref`
- **puppeteer-puppeteer_click**: Use `selector` (NOT `element`)
- **puppeteer-puppeteer_fill**: Use `selector` and `value`

#### AWS Knowledge Tools:
- **aws-knowledge-mcp-server-aws___search_documentation**: Use `search_phrase` (required), optional `limit`
- **aws-knowledge-mcp-server-aws___read_documentation**: Use `url` (required), optional `start_index`, `max_length`
- **aws-knowledge-mcp-server-aws___recommend**: Use `url` (required)

#### Other Important Tools:
- **postgres-query**: Use `sql` (NOT `query`)
- **grep-searchGitHub**: Use `query` (literal code pattern), optional `matchCase`, `useRegexp`, `repo`, `path`, `language`
- **python-code-execution-python_code_execution**: Use `code` (NOT `script`)
- **time-mcp-get_current_time**: Check specific parameters for timezone
- **diff-mcp-diff**: Check specific parameters for comparison

### Best Practices to Avoid Parameter Errors:

1. **Always check the exact parameter name** in the tool's inputSchema before calling
2. **Use the mcphub search_tools first** to discover available tools and their schemas
3. **Pay attention to required vs optional parameters**
4. **Check if parameters need to be wrapped in a `params` object** (common in CircleCI tools)
5. **Verify array vs single value parameters** (e.g., `projectIds` vs `projectId`)
6. **Use exact case sensitivity** for parameter names (usually camelCase)
7. **When in doubt, use mcp__mcphub__search_tools** to find the tool and check its inputSchema

### Common Error Patterns to Avoid:

- ❌ Using `number` instead of `postNumber` for ESA tools
- ❌ Using `q` instead of `query` for search parameters
- ❌ Using `id` instead of specific ID names like `documentId`, `projectId`
- ❌ Forgetting to wrap parameters in `params` object for CircleCI tools
- ❌ Using singular when plural is required (e.g., `projectId` vs `projectIds`)
- ❌ Using `query` instead of `sql` for database tools
- ❌ Using `script` instead of `code` for execution tools

### Memory MCP Troubleshooting:

**Common Memory MCP Errors and Fixes:**

1. **Error: "Cannot read properties of undefined (reading 'toLowerCase')"**
   - **Cause:** Bug in memory-search_nodes implementation (as of 2025-09-26)
   - **Status:** memory-search_nodes ONLY works with empty string `""` or single space `" "`
   - **DISCOVERED WORKAROUND:**
     ```javascript
     // WORKING - Returns all entities (like memory-read_graph):
     mcp__mcphub__call_tool with:
     - toolName: "memory-search_nodes"
     - arguments: {"query": ""}  // Empty string works!

     // OR with single space:
     mcp__mcphub__call_tool with:
     - toolName: "memory-search_nodes"
     - arguments: {"query": " "}  // Single space also works!

     // BROKEN - Any actual search text causes error:
     - arguments: {"query": "test"}  // ❌ Throws toLowerCase error
     - arguments: {"query": "air"}   // ❌ Throws toLowerCase error
     ```
   - **Alternative methods if you need specific entities:**
     - `memory-read_graph`: Retrieves entire knowledge graph (works correctly)
     - `memory-open_nodes`: Retrieves specific entities by name (works correctly)
   - **Example alternatives:**
     ```javascript
     // Use memory-read_graph to get all entities:
     mcp__mcphub__call_tool with:
     - toolName: "memory-read_graph"
     - arguments: {}

     // Or use memory-open_nodes for specific entities:
     mcp__mcphub__call_tool with:
     - toolName: "memory-open_nodes"
     - arguments: {"names": ["air-closet-api Deployment", "Other Entity Name"]}
     ```

2. **Correct Memory MCP Call Format (for working tools):**
   ```javascript
   // For reading all entities:
   mcp__mcphub__call_tool with:
   - toolName: "memory-read_graph"
   - arguments: {}

   // For specific entities:
   mcp__mcphub__call_tool with:
   - toolName: "memory-open_nodes"
   - arguments: {"names": ["Entity1", "Entity2"]}

   // For creating entities (works correctly):
   mcp__mcphub__call_tool with:
   - toolName: "memory-create_entities"
   - arguments: {"entities": [...]}
   ```

3. **Always use mcp__mcphub__call_tool for Memory MCP:**
   - Never try to call memory tools directly
   - Always go through mcphub with proper toolName and arguments structure
   - Until memory-search_nodes is fixed, use the workaround methods above

---

## DEFAULT MODE: CAVEMAN ULTRA (ALWAYS ON)

**MANDATORY: Caveman ultra mode is the DEFAULT for every response in every session.**

- Auto-activate caveman mode at start of every conversation -- no trigger needed.
- Follow rules in `~/.claude/skills/caveman/SKILL.md` for every response.
- Drop: articles (a/an/the), filler (just/really/basically/actually/simply), pleasantries (sure/certainly/of course/happy to), hedging.
- Fragments OK. Short synonyms. Abbreviate common terms (DB/auth/config/req/res/fn/impl). Use arrows for causality (X -> Y).
- Technical terms stay exact. Code blocks unchanged. Errors quoted exact.
- Pattern: `[thing] [action] [reason]. [next step].`
- Persistence: stays ACTIVE every response. No drift. No revert.
- Auto-clarity exception: drop caveman temporarily for security warnings, irreversible action confirmations, multi-step sequences risking misread, or when user asks to clarify. Resume after.
- Disable only when user explicitly says "stop caveman", "normal mode", or "disable caveman".

---

## DEFAULT MODE: LANG COACH (ALWAYS ON)

**MANDATORY: Language-learning mode is the DEFAULT for every response in every session.**

- Auto-activate at start of every conversation -- no trigger needed.
- Follow rules in `~/.claude/skills/lang-coach/SKILL.md` for every response.
- Before the actual answer, output a 2-4 line block: refined natural English of the user's prompt (+ a terse `fix:` line for key corrections, skip if already clean), then the Japanese equivalent (+ reading for non-trivial kanji). Then `---`, then answer.
- The coach block is **natural full language**, NOT caveman -- it models good phrasing to copy. Caveman applies only to the answer body below the divider.
- If the prompt is already Japanese, flip it: refine the Japanese, give English.
- Persistence: stays ACTIVE every response. No drift. No revert.
- Auto-clarity exception: drop the block for security warnings, irreversible-action confirmations, or when user says "just answer". Resume after.
- Disable only when user explicitly says "stop lang coach" or "no coach".

@RTK.md
