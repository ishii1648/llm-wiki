<!-- source: https://strandsagents.com/docs/user-guide/concepts/plugins/ -->
<!-- title: Plugins -->

# Plugins

Plugins allow you to change the typical behavior of an agent. They enable you to introduce concepts like [Skills](https://agentskills.io/specification), [steering](/docs/user-guide/concepts/plugins/steering/), or other behavioral modifications into the agentic loop. Plugins work by taking advantage of the low-level primitives exposed by the Agent class—`model`, `system_prompt`, `messages`, `tools`, and `hooks`—and executing logic to improve an agent’s behavior.

The Strands SDK provides built-in plugins that you can use out of the box:

- **[Skills](/docs/user-guide/concepts/plugins/skills/)** - On-demand, modular instructions that agents discover and activate at runtime following the [Agent Skills specification](https://agentskills.io/specification)
- **[Steering](/docs/user-guide/concepts/plugins/steering/)** - Modular prompting for complex agent tasks through context-aware guidance
- **[Context Offloader](/docs/user-guide/concepts/plugins/context-offloader/)** - Proactively offloads oversized tool results to storage, replacing them with previews and providing a built-in retrieval tool

You can also build and distribute your own plugins to extend agent functionality. See [Get Featured](/docs/community/get-featured) to share your plugins with the community.

## Using Plugins

[Section titled “Using Plugins”](#using-plugins)

Plugins are passed to agents during initialization via the `plugins` parameter:

- [Python](#tab-panel-1759)
- [TypeScript](#tab-panel-1760)

```
from strands import Agent


from strands.vended_plugins.steering import LLMSteeringHandler


# Create an agent with plugins


agent = Agent(


tools=[my_tool],


plugins=[LLMSteeringHandler(system_prompt="Guide the agent...")]


)
```

```
import { Agent, Plugin, Tool } from '@strands-agents/sdk'


// Create an agent with plugins


const agent = new Agent({


tools: [myTool],


plugins: [new GuidancePlugin('Guide the agent...')],


})
```

## Building Plugins

[Section titled “Building Plugins”](#building-plugins)

This section walks through how to build a custom plugin step by step.

### Basic Plugin Structure

[Section titled “Basic Plugin Structure”](#basic-plugin-structure)

A plugin is a class that extends the `Plugin` base class and defines a `name` property. For example, a simple logging plugin would look like this:

- [Python](#tab-panel-1761)
- [TypeScript](#tab-panel-1762)

```
from strands import Agent, tool


from strands.plugins import Plugin, hook


from strands.hooks import BeforeToolCallEvent, AfterToolCallEvent


class LoggingPlugin(Plugin):


"""A plugin that logs all tool calls and provides a utility tool."""


name = "logging-plugin"


@hook


def log_before_tool(self, event: BeforeToolCallEvent) -> None:


"""Called before each tool execution."""


print(f"[LOG] Calling tool: {event.tool_use['name']}")


print(f"[LOG] Input: {event.tool_use['input']}")


@hook


def log_after_tool(self, event: AfterToolCallEvent) -> None:


"""Called after each tool execution."""


print(f"[LOG] Tool completed: {event.tool_use['name']}")


@tool


def debug_print(self, message: str) -> str:


"""Print a debug message.


Args:


message: The message to print


"""


print(f"[DEBUG] {message}")


return f"Printed: {message}"


# Using the plugin


agent = Agent(plugins=[LoggingPlugin()])


agent("Calculate 2 + 2 and print the result")
```

```
import { Agent, FunctionTool, Plugin, Tool } from '@strands-agents/sdk'


import { BeforeToolCallEvent, AfterToolCallEvent } from '@strands-agents/sdk'


class LoggingPlugin implements Plugin {


name = 'logging-plugin'


initAgent(agent: LocalAgent): void {


// Register hooks manually in initAgent


agent.addHook(BeforeToolCallEvent, (event) => {


console.log(`[LOG] Calling tool: ${event.toolUse.name}`)


console.log(`[LOG] Input: ${JSON.stringify(event.toolUse.input)}`)


})


agent.addHook(AfterToolCallEvent, (event) => {


console.log(`[LOG] Tool completed: ${event.toolUse.name}`)


})


}


getTools(): Tool[] {


// Provide additional tools via the plugin


return [debugPrintTool]


}


}


// Using the plugin


const agent = new Agent({


plugins: [new LoggingPlugin()],


})


// Custom tool to add


const debugPrintTool = new FunctionTool({


name: 'debug_print',


description: 'Print a debug message',


inputSchema: {


type: 'object',


properties: {


message: { type: 'string', description: 'The message to print' },


},


required: ['message'],


},


callback: async (input: unknown) => {


const typedInput = input as { message: string }


console.log(`[DEBUG] ${typedInput.message}`)


return `Printed: ${typedInput.message}`


},


})
```

### How It Works Under the Hood

[Section titled “How It Works Under the Hood”](#how-it-works-under-the-hood)

When you attach a plugin to an agent, the following happens:

- [Python](#tab-panel-1757)
- [TypeScript](#tab-panel-1758)

1. **Discovery**: The `Plugin` base class scans for methods decorated with `@hook` and `@tool`
2. **Hook Registration**: Each `@hook` method is registered with the agent’s hook registry based on its event type hint
3. **Tool Registration**: Each `@tool` method is added to the agent’s tools list
4. **Initialization**: The `init_agent(agent)` method is called for any custom setup

1. **Tool Registration**: The `getTools()` method is called to get tools provided by the plugin
2. **Initialization**: The `initAgent(agent)` method is called for hook registration and setup
3. **Hook Registration**: In `initAgent`, use `agent.addHook()` to register event callbacks manually

**Note**: TypeScript does not use `@hook` or `@tool` decorators. Instead, tools are returned from `getTools()` and hooks are registered manually in `initAgent()`.

```
flowchart TD


A[Plugin Attached] --> B["Discover Tools\n(@tool / getTools)"]


A --> C["Initialize\n(init_agent / initAgent)"]


B --> D[Add Tools]


C --> E["Register Hooks\n(@hook / addHook)"]


D --> F[Plugin Ready]


E --> F
```

### Registering Hooks in Plugins

[Section titled “Registering Hooks in Plugins”](#registering-hooks-in-plugins)

- [Python](#tab-panel-1769)
- [TypeScript](#tab-panel-1770)

#### The `@hook` Decorator

[Section titled “The @hook Decorator”](#the-hook-decorator)

The `@hook` decorator marks methods as hook callbacks. The event type is automatically inferred from the type hint:

```
from strands.plugins import Plugin, hook


from strands.hooks import BeforeModelCallEvent, AfterModelCallEvent


class ModelMonitorPlugin(Plugin):


name = "model-monitor"


@hook


def before_model(self, event: BeforeModelCallEvent) -> None:


"""Event type inferred from type hint."""


print("Model call starting...")


@hook


def on_model_event(self, event: BeforeModelCallEvent | AfterModelCallEvent) -> None:


"""Handle multiple event types with a union."""


print(f"Model event: {type(event).__name__}")
```

#### Manual Hook Registration

[Section titled “Manual Hook Registration”](#manual-hook-registration)

TypeScript plugins register hooks manually in the `initAgent` method using `agent.addHook()`:

```
import { Plugin } from '@strands-agents/sdk'


import { BeforeModelCallEvent, AfterModelCallEvent } from '@strands-agents/sdk'


class ModelMonitorPlugin implements Plugin {


name = 'model-monitor'


initAgent(agent: LocalAgent): void {


// Register a hook for a single event type


agent.addHook(BeforeModelCallEvent, () => {


console.log('Model call starting...')


})


// Register the same handler for multiple event types (union equivalent)


const onModelEvent = (event: BeforeModelCallEvent | AfterModelCallEvent) => {


console.log(`Model event: ${event.constructor.name}`)


}


agent.addHook(BeforeModelCallEvent, onModelEvent)


agent.addHook(AfterModelCallEvent, onModelEvent)


}


}
```

### Manual Hook and Tool Registration

[Section titled “Manual Hook and Tool Registration”](#manual-hook-and-tool-registration)

For more control, you can manually register hooks and tools in the `init_agent` method:

- [Python](#tab-panel-1763)
- [TypeScript](#tab-panel-1764)

```
from strands.plugins import Plugin


from strands.hooks import BeforeToolCallEvent


class ManualPlugin(Plugin):


name = "manual-plugin"


def __init__(self, verbose: bool = False):


super().__init__()


self.verbose = verbose


def init_agent(self, agent: "Agent") -> None:


# Conditionally register additional hooks


if self.verbose:


agent.add_hook(self.verbose_log, BeforeToolCallEvent)


# Access agent properties


print(f"Attached to agent with {len(agent.tool_names)} tools")


def verbose_log(self, event: BeforeToolCallEvent) -> None:


print(f"[VERBOSE] {event.tool_use}")
```

```
import { Plugin } from '@strands-agents/sdk'


import { BeforeToolCallEvent } from '@strands-agents/sdk'


class ManualPlugin implements Plugin {


private verbose: boolean


name = 'manual-plugin'


constructor(options: { verbose?: boolean } = {}) {


this.verbose = options.verbose ?? false


}


initAgent(agent: LocalAgent): void {


// Conditionally register additional hooks


if (this.verbose) {


agent.addHook(BeforeToolCallEvent, (event) => {


console.log(`[VERBOSE] ${JSON.stringify(event.toolUse)}`)


})


}


// Access agent tools via toolRegistry


console.log(`Attached to agent with ${agent.toolRegistry.list().length} tools`)


}


}
```

### Managing Plugin State

[Section titled “Managing Plugin State”](#managing-plugin-state)

Plugins can maintain state that persists across agent invocations. For state that needs to be serialized or shared, use the [Agent State](/docs/user-guide/concepts/agents/state/) mechanism:

- [Python](#tab-panel-1765)
- [TypeScript](#tab-panel-1766)

```
from strands import Agent


from strands.plugins import Plugin, hook


from strands.hooks import BeforeToolCallEvent, AfterToolCallEvent


class MetricsPlugin(Plugin):


"""Track tool execution metrics using agent state."""


name = "metrics-plugin"


def init_agent(self, agent: "Agent") -> None:


# Initialize state values if not present


if "metrics_call_count" not in agent.state:


agent.state.set("metrics_call_count", 0)


@hook


def count_calls(self, event: BeforeToolCallEvent) -> None:


current = event.agent.state.get("metrics_call_count", 0)


event.agent.state.set("metrics_call_count", current + 1)


# Usage


agent = Agent(plugins=[MetricsPlugin()])


agent("Do some work")


print(f"Tool calls: {agent.state.get('metrics_call_count')}")
```

```
import { Agent, Plugin } from '@strands-agents/sdk'


import { BeforeToolCallEvent } from '@strands-agents/sdk'


class MetricsPlugin implements Plugin {


name = 'metrics-plugin'


initAgent(agent: LocalAgent): void {


// Initialize state values if not present


if (!agent.appState.get('metrics_call_count')) {


agent.appState.set('metrics_call_count', 0)


}


agent.addHook(BeforeToolCallEvent, () => {


const current = (agent.appState.get('metrics_call_count') as number) ?? 0


agent.appState.set('metrics_call_count', current + 1)


})


}


}


// Usage


const metricsPlugin = new MetricsPlugin()


const agent = new Agent({


plugins: [metricsPlugin],


})


console.log(`Tool calls: ${agent.appState.get('metrics_call_count')}`)
```

See [Agent State](/docs/user-guide/concepts/agents/state/) for more information on state management.

### Async Plugin Initialization

[Section titled “Async Plugin Initialization”](#async-plugin-initialization)

Plugins can perform asynchronous initialization:

- [Python](#tab-panel-1767)
- [TypeScript](#tab-panel-1768)

```
import asyncio


from strands.plugins import Plugin, hook


from strands.hooks import BeforeToolCallEvent


class AsyncConfigPlugin(Plugin):


name = "async-config"


async def init_agent(self, agent: "Agent") -> None:


# Async initialization


self.config = await self.load_config()


async def load_config(self) -> dict:


await asyncio.sleep(0.1)  # Simulate async operation


return {"setting": "value"}


@hook


def use_config(self, event: BeforeToolCallEvent) -> None:


print(f"Config: {self.config}")
```

```
import { Plugin } from '@strands-agents/sdk'


import { BeforeToolCallEvent } from '@strands-agents/sdk'


class AsyncConfigPlugin implements Plugin {


private config: Record<string, unknown> = {}


name = 'async-config'


async initAgent(agent: LocalAgent): Promise<void> {


// Async initialization


this.config = await this.loadConfig()


agent.addHook(BeforeToolCallEvent, () => {


console.log(`Config: ${JSON.stringify(this.config)}`)


})


}


private async loadConfig(): Promise<Record<string, unknown>> {


await new Promise((resolve) => setTimeout(resolve, 100)) // Simulate async operation


return { setting: 'value' }


}


}
```

## Next Steps

[Section titled “Next Steps”](#next-steps)

- [Hooks](/docs/user-guide/concepts/agents/hooks/) - Learn about the underlying hook system
- [Steering](/docs/user-guide/concepts/plugins/steering/) - Explore the built-in steering plugin
- [Context Offloader](/docs/user-guide/concepts/plugins/context-offloader/) - Manage large tool results proactively
- [Get Featured](/docs/community/get-featured) - Share your plugins with the community
