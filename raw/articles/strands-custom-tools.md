<!-- source: https://strandsagents.com/docs/user-guide/concepts/tools/custom-tools/ -->
<!-- title: Creating Custom Tools -->

# Creating Custom Tools

There are multiple approaches to defining custom tools in Strands, with differences between Python and TypeScript implementations.

- [Python](#tab-panel-1881)
- [TypeScript](#tab-panel-1882)

Python supports three approaches to defining tools:

- **Python functions with the [`@tool`](/docs/api/python/strands.tools.decorator/#tool) decorator**: Transform regular Python functions into tools by adding a simple decorator. This approach leverages Python’s docstrings and type hints to automatically generate tool specifications.
- **Class-based tools with the [`@tool`](/docs/api/python/strands.tools.decorator/#tool) decorator**: Create tools within classes to maintain state and leverage object-oriented programming patterns.
- **Python modules following a specific format**: Define tools by creating Python modules that contain a tool specification and a matching function. This approach gives you more control over the tool’s definition and is useful for dependency-free implementations of tools.

TypeScript supports two main approaches:

- **tool() function with [Zod](https://zod.dev/) or JSON schemas**: Create tools using the `tool()` function with either Zod schemas for type-safe validated input, or plain JSON Schema objects for schema-only definitions without runtime validation.
- **Class-based tools extending FunctionTool**: Create tools within classes to maintain shared state and resources.

## Tool Creation Examples

[Section titled “Tool Creation Examples”](#tool-creation-examples)

### Basic Example

[Section titled “Basic Example”](#basic-example)

- [Python](#tab-panel-1875)
- [TypeScript](#tab-panel-1876)

Here’s a simple example of a function decorated as a tool:

```
from strands import tool


@tool


def weather_forecast(city: str, days: int = 3) -> str:


"""Get weather forecast for a city.


Args:


city: The name of the city


days: Number of days for the forecast


"""


return f"Weather forecast for {city} for the next {days} days..."
```

The decorator extracts information from your function’s docstring to create the tool specification. The first paragraph becomes the tool’s description, and the “Args” section provides parameter descriptions. These are combined with the function’s type hints to create a complete tool specification.

Here’s a simple example of a function based tool with Zod:

```
const weatherTool = tool({


name: 'weather_forecast',


description: 'Get weather forecast for a city',


inputSchema: z.object({


city: z.string().describe('The name of the city'),


days: z.number().default(3).describe('Number of days for the forecast'),


}),


callback: (input) => {


return `Weather forecast for ${input.city} for the next ${input.days} days...`


},


})
```

The `tool()` function accepts either a [Zod](https://zod.dev/) schema or a plain JSON Schema object as `inputSchema`. With Zod, input is validated at runtime and the callback receives typed input. With JSON Schema, the schema is passed through as-is and the callback receives `unknown`.

Here’s the same tool using a JSON Schema object instead:

```
const weatherTool = tool({


name: 'weather_forecast',


description: 'Get weather forecast for a city',


inputSchema: {


type: 'object',


properties: {


city: { type: 'string', description: 'The name of the city' },


days: { type: 'number', description: 'Number of days for the forecast' },


},


required: ['city'],


},


callback: (input) => {


const { city, days = 3 } = input as { city: string; days?: number }


return `Weather forecast for ${city} for the next ${days} days...`


},


})
```

### Overriding Tool Name, Description, and Schema

[Section titled “Overriding Tool Name, Description, and Schema”](#overriding-tool-name-description-and-schema)

- [Python](#tab-panel-1857)
- [TypeScript](#tab-panel-1858)

You can override the tool name, description, and input schema by providing them as arguments to the decorator:

```
@tool(name="get_weather", description="Retrieves weather forecast for a specified location")


def weather_forecast(city: str, days: int = 3) -> str:


"""Implementation function for weather forecasting.


Args:


city: The name of the city


days: Number of days for the forecast


"""


return f"Weather forecast for {city} for the next {days} days..."
```

In TypeScript, the tool name and description are always provided explicitly in the `tool()` configuration:

```
const weatherTool = tool({


name: 'get_weather',


description: 'Retrieves weather forecast for a specified location',


inputSchema: z.object({


city: z.string().describe('The name of the city'),


days: z.number().default(3).describe('Number of days for the forecast'),


}),


callback: (input: { city: any; days: any }) => {


return `Weather forecast for ${input.city} for the next ${input.days} days...`


},


})
```

Tool names must match `^[a-zA-Z0-9_-]+$` and be 1 to 64 characters long. Names that do not match this format are replaced with `INVALID_TOOL_NAME` on assistant messages before they are sent to the model, so the request still succeeds but the model can no longer reference the original name.

### Overriding Input Schema

[Section titled “Overriding Input Schema”](#overriding-input-schema)

- [Python](#tab-panel-1859)
- [TypeScript](#tab-panel-1860)

You can provide a custom JSON schema to override the automatically generated one:

```
@tool(


inputSchema={


"json": {


"type": "object",


"properties": {


"shape": {


"type": "string",


"enum": ["circle", "rectangle"],


"description": "The shape type"


},


"radius": {"type": "number", "description": "Radius for circle"},


"width": {"type": "number", "description": "Width for rectangle"},


"height": {"type": "number", "description": "Height for rectangle"}


},


"required": ["shape"]


}


}


)


def calculate_area(shape: str, radius: float = None, width: float = None, height: float = None) -> float:


"""Calculate area of a shape."""


if shape == "circle":


return 3.14159 * radius ** 2


elif shape == "rectangle":


return width * height


return 0.0
```

In TypeScript, `inputSchema` is always provided explicitly in the `tool()` configuration - as either a Zod schema or a JSON Schema object. See the [basic example](#basic-example) above for both approaches.

## Using and Customizing Tools:

[Section titled “Using and Customizing Tools:”](#using-and-customizing-tools)

### Loading Function-Based Tools

[Section titled “Loading Function-Based Tools”](#loading-function-based-tools)

To use function-based tools, simply pass them to the agent:

- [Python](#tab-panel-1853)
- [TypeScript](#tab-panel-1854)

```
agent = Agent(


tools=[weather_forecast]


)
```

```
const agent = new Agent({


tools: [weatherTool]


})
```

### Custom Return Type

[Section titled “Custom Return Type”](#custom-return-type)

- [Python](#tab-panel-1861)
- [TypeScript](#tab-panel-1862)

By default, your function’s return value is automatically formatted as a text response. However, if you need more control over the response format, you can return a dictionary with a specific structure:

```
@tool


def fetch_data(source_id: str) -> dict:


"""Fetch data from a specified source.


Args:


source_id: Identifier for the data source


"""


try:


data = some_other_function(source_id)


return {


"status": "success",


"content": [ {


"json": data,


}]


}


except Exception as e:


return {


"status": "error",


"content": [


{"text": f"Error:{e}"}


]


}
```

In Typescript, your tool’s return value is automatically converted into a `ToolResultBlock`. You can return **any** JSON serializable object:

```
const weatherTool = tool({


name: 'get_weather',


description: 'Retrieves weather forecast for a specified location',


inputSchema: z.object({


city: z.string().describe('The name of the city'),


days: z.number().default(3).describe('Number of days for the forecast'),


}),


callback: (input: { city: any; days: any }) => {


return {


city: input.city,


days: input.days,


forecast: `Weather forecast for ${input.city} for the next ${input.days} days...`,


}


},


})
```

For more details, see the [Tool Response Format](#tool-response-format) section below.

### Async Invocation

[Section titled “Async Invocation”](#async-invocation)

Function tools may also be defined async. Strands will invoke all async tools concurrently.

- [Python](#tab-panel-1863)
- [TypeScript](#tab-panel-1864)

```
import asyncio


from strands import Agent, tool


@tool


async def call_api() -> str:


"""Call API asynchronously."""


await asyncio.sleep(5)  # simulated api call


return "API result"


async def async_example():


agent = Agent(tools=[call_api])


await agent.invoke_async("Can you call my API?")


asyncio.run(async_example())
```

**Async callback:**

```
const callApiTool = tool({


name: 'call_api',


description: 'Call API asynchronously',


inputSchema: z.object({}),


callback: async (): Promise<string> => {


await new Promise((resolve) => setTimeout(resolve, 5000)) // simulated api call


return 'API result'


},


})


const agent = new Agent({ tools: [callApiTool] })


await agent.invoke('Can you call my API?')
```

**AsyncGenerator callback:**

```
const insertDataTool = tool({


name: 'insert_data',


description: 'Insert data with progress updates',


inputSchema: z.object({


table: z.string().describe('The table name'),


data: z.record(z.string(), z.any()).describe('The data to insert'),


}),


callback: async function* (input: {


table: string


data: Record<string, any>


}): AsyncGenerator<string, string, unknown> {


yield 'Starting data insertion...'


await new Promise((resolve) => setTimeout(resolve, 1000))


yield 'Validating data...'


await new Promise((resolve) => setTimeout(resolve, 1000))


return `Inserted data into ${input.table}: ${JSON.stringify(input.data)}`


},


})
```

### ToolContext

[Section titled “ToolContext”](#toolcontext)

Tools can access their execution context to interact with the invoking agent, current tool use data, and invocation state. The [`ToolContext`](/docs/api/python/strands.types.tools/#ToolContext) provides this access:

- [Python](#tab-panel-1865)
- [TypeScript](#tab-panel-1866)

In Python, set `context=True` in the decorator and include a `tool_context` parameter:

```
from strands import tool, Agent, ToolContext


@tool(context=True)


def get_self_name(tool_context: ToolContext) -> str:


return f"The agent name is {tool_context.agent.name}"


@tool(context=True)


def get_tool_use_id(tool_context: ToolContext) -> str:


return f"Tool use is {tool_context.tool_use["toolUseId"]}"


@tool(context=True)


def get_invocation_state(tool_context: ToolContext) -> str:


return f"Invocation state: {tool_context.invocation_state["custom_data"]}"


agent = Agent(tools=[get_self_name, get_tool_use_id, get_invocation_state], name="Best agent")


agent("What is your name?")


agent("What is the tool use id?")


agent("What is the invocation state?", custom_data="You're the best agent ;)")
```

In TypeScript, the context is passed as an optional second parameter to the callback function:

```
const getAgentInfoTool = tool({


name: 'get_agent_info',


description: 'Get information about the agent',


inputSchema: z.object({}),


callback: (input, context?: ToolContext): string => {


// Access agent state through context


return `Agent has ${context?.agent.messages.length} messages in history`


},


})


const getToolUseIdTool = tool({


name: 'get_tool_use_id',


description: 'Get the tool use ID',


inputSchema: z.object({}),


callback: (input, context?: ToolContext): string => {


return `Tool use is ${context?.toolUse.toolUseId}`


},


})


const agent = new Agent({ tools: [getAgentInfoTool, getToolUseIdTool] })


await agent.invoke('What is your information?')


await agent.invoke('What is the tool use id?')
```

### Custom ToolContext Parameter Name

[Section titled “Custom ToolContext Parameter Name”](#custom-toolcontext-parameter-name)

- [Python](#tab-panel-1851)
- [TypeScript](#tab-panel-1852)

To use a different parameter name for ToolContext, specify the desired name as the value of the `@tool.context` argument:

```
from strands import tool, Agent, ToolContext


@tool(context="context")


def get_self_name(context: ToolContext) -> str:


return f"The agent name is {context.agent.name}"


agent = Agent(tools=[get_self_name], name="Best agent")


agent("What is your name?")
```

```
// Not supported in TypeScript
```

#### Accessing State in Tools

[Section titled “Accessing State in Tools”](#accessing-state-in-tools)

- [Python](#tab-panel-1879)
- [TypeScript](#tab-panel-1880)

The `invocation_state` attribute in `ToolContext` provides access to data passed through the agent invocation. This is particularly useful for:

1. **Request Context**: Access session IDs, user information, or request-specific data
2. **Multi-Agent Shared State**: In [Graph](/docs/user-guide/concepts/multi-agent/graph/) and [Swarm](/docs/user-guide/concepts/multi-agent/swarm/) patterns, access state shared across all agents
3. **Per-Invocation Overrides**: Override behavior or settings for specific requests

```
from strands import tool, Agent, ToolContext


import requests


@tool(context=True)


def api_call(query: str, tool_context: ToolContext) -> dict:


"""Make an API call with user context.


Args:


query: The search query to send to the API


tool_context: Context containing user information


"""


user_id = tool_context.invocation_state.get("user_id")


response = requests.get(


"https://api.example.com/search",


headers={"X-User-ID": user_id},


params={"q": query}


)


return response.json()


agent = Agent(tools=[api_call])


result = agent("Get my profile data", user_id="user123")
```

**Invocation State Compared To Other Approaches**

It’s important to understand how invocation state compares to other approaches that impact tool execution:

- **Tool Parameters**: Use for data that the LLM should reason about and provide based on the user’s request. Examples include search queries, file paths, calculation inputs, or any data the agent needs to determine from context.
- **Invocation State**: Use for context and configuration that should not appear in prompts but affects tool behavior. Best suited for parameters that can change between agent invocations. Examples include user IDs for personalization, session IDs, or user flags.
- **[Class-based tools](#class-based-tools)**: Use for configuration that doesn’t change between requests and requires initialization. Examples include API keys, database connection strings, service endpoints, or shared resources that need setup.

In TypeScript, tools access **invocation state** through `context.invocationState`. This per-invocation `Record<string, unknown>` is passed in via `InvokeOptions` and shared by reference across hooks and tools for the duration of one invocation:

```
const apiCallTool = tool({


name: 'api_call',


description: 'Make an API call with user context',


inputSchema: z.object({


query: z.string().describe('The search query'),


}),


callback: async (input, context) => {


if (!context) {


throw new Error('Context is required')


}


// Access per-invocation state via context.invocationState


const userId = context.invocationState.userId as string | undefined


const response = await fetch('https://api.example.com/search', {


method: 'GET',


headers: { 'X-User-ID': userId || '' },


})


return response.json()


},


})


const agent = new Agent({ tools: [apiCallTool] })


// Pass invocation state when invoking


const result = await agent.invoke('Get my profile data', {


invocationState: { userId: 'user123' },


})
```

Invocation state is useful for:

1. **Request Context**: Access session IDs, user information, or request-specific data without polluting model context
2. **Multi-Agent Shared State**: In [Graph](/docs/user-guide/concepts/multi-agent/graph/) and [Swarm](/docs/user-guide/concepts/multi-agent/swarm/) patterns, access state shared across all agents
3. **Cross-Hook Counters**: Track tool call counts, model calls, or custom metrics across hooks and tools within a single invocation

**Invocation State Compared To Other Approaches**

- **Tool Parameters**: Data the LLM should reason about — search queries, file paths, user requests.
- **Invocation State** (`context.invocationState`): Request-scoped context that should not appear in prompts but affects tool behavior. Ephemeral — scoped to one invocation and accepts arbitrary values.
- **Agent State** (`context.agent.appState`): Durable key-value storage that persists across invocations. JSON-serializable and deep-copied on read/write. Use for configuration that doesn’t change between requests.
- **[Class-based tools](#class-based-tools)**: Instance-level configuration that requires initialization. Use for API keys, database connections, or shared resources.

### Tool Streaming

[Section titled “Tool Streaming”](#tool-streaming)

- [Python](#tab-panel-1867)
- [TypeScript](#tab-panel-1868)

Async tools can yield intermediate results to provide real-time progress updates. Each yielded value becomes a [streaming event](/docs/user-guide/concepts/streaming/), with the final value serving as the tool’s return result:

```
from datetime import datetime


import asyncio


from strands import tool


@tool


async def process_dataset(records: int) -> str:


"""Process records with progress updates."""


start = datetime.now()


for i in range(records):


await asyncio.sleep(0.1)


if i % 10 == 0:


elapsed = datetime.now() - start


yield f"Processed {i}/{records} records in {elapsed.total_seconds():.1f}s"


yield f"Completed {records} records in {(datetime.now() - start).total_seconds():.1f}s"
```

Stream events contain a `tool_stream_event` dictionary with `tool_use` (invocation info) and `data` (yielded value) fields:

```
async def tool_stream_example():


agent = Agent(tools=[process_dataset])


async for event in agent.stream_async("Process 50 records"):


if tool_stream := event.get("tool_stream_event"):


if update := tool_stream.get("data"):


print(f"Progress: {update}")


asyncio.run(tool_stream_example())
```

```
const processDatasetTool = tool({


name: 'process_dataset',


description: 'Process records with progress updates',


inputSchema: z.object({


records: z.number().describe('Number of records to process'),


}),


callback: async function* (input: {


records: number


}): AsyncGenerator<string, string, unknown> {


const start = Date.now()


for (let i = 0; i < input.records; i++) {


await new Promise((resolve) => setTimeout(resolve, 100))


if (i % 10 === 0) {


const elapsed = (Date.now() - start) / 1000


yield `Processed ${i}/${input.records} records in ${elapsed.toFixed(1)}s`


}


}


const elapsed = (Date.now() - start) / 1000


return `Completed ${input.records} records in ${elapsed.toFixed(1)}s`


},


})


const agent = new Agent({ tools: [processDatasetTool] })


for await (const event of agent.stream('Process 50 records')) {


if (event.type === 'toolStreamUpdateEvent') {


console.log(`Progress: ${event.event.data}`)


}


}
```

## Class-Based Tools

[Section titled “Class-Based Tools”](#class-based-tools)

Class-based tools allow you to create tools that maintain state and leverage object-oriented programming patterns. This approach is useful when your tools need to share resources, maintain context between invocations, follow object-oriented design principles, customize tools before passing them to an agent, or create different tool configurations for different agents.

### Example with Multiple Tools in a Class

[Section titled “Example with Multiple Tools in a Class”](#example-with-multiple-tools-in-a-class)

You can define multiple tools within the same class to create a cohesive set of related functionality:

- [Python](#tab-panel-1869)
- [TypeScript](#tab-panel-1870)

```
from strands import Agent, tool


class DatabaseTools:


def __init__(self, connection_string):


self.connection = self._establish_connection(connection_string)


def _establish_connection(self, connection_string):


# Set up database connection


return {"connected": True, "db": "example_db"}


@tool


def query_database(self, sql: str) -> dict:


"""Run a SQL query against the database.


Args:


sql: The SQL query to execute


"""


# Uses the shared connection


return {"results": f"Query results for: {sql}", "connection": self.connection}


@tool


def insert_record(self, table: str, data: dict) -> str:


"""Insert a new record into the database.


Args:


table: The table name


data: The data to insert as a dictionary


"""


# Also uses the shared connection


return f"Inserted data into {table}: {data}"


# Usage


db_tools = DatabaseTools("example_connection_string")


agent = Agent(


tools=[db_tools.query_database, db_tools.insert_record]


)
```

When you use the [`@tool`](/docs/api/python/strands.tools.decorator/#tool) decorator on a class method, the method becomes bound to the class instance when instantiated. This means the tool function has access to the instance’s attributes and can maintain state between invocations.

```
class DatabaseTools {


private connection: { connected: boolean; db: string }


readonly queryTool: ReturnType<typeof tool>


readonly insertTool: ReturnType<typeof tool>


constructor(connectionString: string) {


// Establish connection


this.connection = { connected: true, db: 'example_db' }


const connection = this.connection


// Create query tool


this.queryTool = tool({


name: 'query_database',


description: 'Run a SQL query against the database',


inputSchema: z.object({


sql: z.string().describe('The SQL query to execute'),


}),


callback: (input) => {


return { results: `Query results for: ${input.sql}`, connection }


},


})


// Create insert tool


this.insertTool = tool({


name: 'insert_record',


description: 'Insert a new record into the database',


inputSchema: z.object({


table: z.string().describe('The table name'),


data: z.record(z.string(), z.any()).describe('The data to insert'),


}),


callback: (input) => {


return `Inserted data into ${input.table}: ${JSON.stringify(input.data)}`


},


})


}


}


// Usage


async function useDatabaseTools() {


const dbTools = new DatabaseTools('example_connection_string')


const agent = new Agent({


tools: [dbTools.queryTool, dbTools.insertTool],


})


}
```

In TypeScript, you can create tools within a class and store them as properties. The tools can access the class’s private state through closures.

## Tool Response Format

[Section titled “Tool Response Format”](#tool-response-format)

Tools can return responses in various formats using the [`ToolResult`](/docs/api/python/strands.types.tools/#ToolResult) structure. This structure provides flexibility for returning different types of content while maintaining a consistent interface.

#### ToolResult Structure

[Section titled “ToolResult Structure”](#toolresult-structure)

- [Python](#tab-panel-1871)
- [TypeScript](#tab-panel-1872)

The [`ToolResult`](/docs/api/python/strands.types.tools/#ToolResult) dictionary has the following structure:

```
{


"toolUseId": str,       # The ID of the tool use request (should match the incoming request).  Optional


"status": str,          # Either "success" or "error"


"content": List[dict]   # A list of content items with different possible formats


}
```

The ToolResult schema:

```
{


type: 'toolResultBlock'


toolUseId: string


status: 'success' | 'error'


content: Array<ToolResultContent>


error?: Error


}
```

#### Content Types

[Section titled “Content Types”](#content-types)

The `content` field is a list of content blocks, where each block can contain:

- `text`: A string containing text output
- `json`: Any JSON-serializable data structure

#### Response Examples

[Section titled “Response Examples”](#response-examples)

- [Python](#tab-panel-1873)
- [TypeScript](#tab-panel-1874)

**Success Response:**

```
{


"toolUseId": "tool-123",


"status": "success",


"content": [


{"text": "Operation completed successfully"},


{"json": {"results": [1, 2, 3], "total": 3}}


]


}
```

**Error Response:**

```
{


"toolUseId": "tool-123",


"status": "error",


"content": [


{"text": "Error: Unable to process request due to invalid parameters"}


]


}
```

**Success Response:**

The output structure of a successful tool response:

```
{


"type": "toolResultBlock",


"toolUseId": "tooluse_xq6vYsQ-QcGZOPcIx0yM3A",


"status": "success",


"content": [


{


"type": "jsonBlock",


"json": {


"result": "The letter 'r' appears 3 time(s) in 'strawberry'"


}


}


]


}
```

**Error Response:**

The output structure of a unsuccessful tool response:

```
{


"type": "toolResultBlock",


"toolUseId": "tooluse_rFoPosVKQ7WfYRfw_min8Q",


"status": "error",


"content": [


{


"type": "textBlock",


"text": "Error: Test error"


}


],


"error": Error // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error


}
```

#### Tool Result Handling

[Section titled “Tool Result Handling”](#tool-result-handling)

- [Python](#tab-panel-1877)
- [TypeScript](#tab-panel-1878)

When using the [`@tool`](/docs/api/python/strands.tools.decorator/#tool) decorator, your function’s return value is automatically converted to a proper [`ToolResult`](/docs/api/python/strands.types.tools/#ToolResult):

1. If you return a string or other simple value, it’s wrapped as `{"text": str(result)}`
2. If you return a dictionary with the proper [`ToolResult`](/docs/api/python/strands.types.tools/#ToolResult) structure, it’s used directly
3. If an exception occurs, it’s converted to an error response

The `tool()` function automatically handles return value conversion:

1. Any of the following types are converted to a ToolResult schema: `string | number | boolean | null | { [key: string]: JSONValue } | JSONValue[]`
2. Exceptions are caught and converted to error responses

## Module Based Tools (python only)

[Section titled “Module Based Tools (python only)”](#module-based-tools-python-only)

- [Python](#tab-panel-1849)

An alternative approach is to define a tool as a Python module with a specific structure. This enables creating tools that don’t depend on the SDK directly.

A Python module tool requires two key components:

1. A `TOOL_SPEC` variable that defines the tool’s name, description, and input schema
2. A function with the same name as specified in the tool spec that implements the tool’s functionality


### Basic Example

[Section titled “Basic Example”](#basic-example-1)

- [Python](#tab-panel-1855)

Here’s how you would implement the same weather forecast tool as a module:

weather\_forecast.py

```
from typing import Any


# 1. Tool Specification


TOOL_SPEC = {


"name": "weather_forecast",


"description": "Get weather forecast for a city.",


"inputSchema": {


"json": {


"type": "object",


"properties": {


"city": {


"type": "string",


"description": "The name of the city"


},


"days": {


"type": "integer",


"description": "Number of days for the forecast",


"default": 3


}


},


"required": ["city"]


}


}


}


# 2. Tool Function


def weather_forecast(tool, **kwargs: Any):


# Extract tool parameters


tool_use_id = tool["toolUseId"]


tool_input = tool["input"]


# Get parameter values


city = tool_input.get("city", "")


days = tool_input.get("days", 3)


# Tool implementation


result = f"Weather forecast for {city} for the next {days} days..."


# Return structured response


return {


"toolUseId": tool_use_id,


"status": "success",


"content": [{"text": result}]


}
```


### Loading Module Tools

[Section titled “Loading Module Tools”](#loading-module-tools)

- [Python](#tab-panel-1850)

To use a module-based tool, import the module and pass it to the agent:

```
from strands import Agent


import weather_forecast


agent = Agent(


tools=[weather_forecast]


)
```

Alternatively, you can load a tool by passing in a path:

```
from strands import Agent


agent = Agent(


tools=["./weather_forecast.py"]


)
```


### Async Invocation

[Section titled “Async Invocation”](#async-invocation-1)

- [Python](#tab-panel-1856)

Similar to decorated tools, users may define their module tools async.

```
TOOL_SPEC = {


"name": "call_api",


"description": "Call my API asynchronously.",


"inputSchema": {


"json": {


"type": "object",


"properties": {},


"required": []


}


}


}


async def call_api(tool, **kwargs):


await asyncio.sleep(5)  # simulated api call


result = "API result"


return {


"toolUseId": tool["toolUseId"],


"status": "success",


"content": [{"text": result}],


}
```
