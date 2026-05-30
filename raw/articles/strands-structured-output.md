<!-- source: https://strandsagents.com/docs/user-guide/concepts/agents/structured-output/ -->
<!-- title: Structured Output -->

# Structured Output

## Introduction

[Section titled “Introduction”](#introduction)

Structured output enables you to get type-safe, validated responses from language models using schema definitions. Instead of receiving raw text that you need to parse, you can define the exact structure you want and receive a validated object that matches your schema. This transforms unstructured LLM outputs into reliable, program-friendly data structures that integrate seamlessly with your application’s type system and validation rules.

In Python, structured output uses [Pydantic](https://docs.pydantic.dev/latest/concepts/models/) models. In TypeScript, it uses [Zod](https://zod.dev/) schemas for runtime validation and type inference.

```
flowchart LR


A[Schema Definition] --> B[Agent Invocation]


B --> C[LLM] --> D[Validated Object]


D --> E[AgentResult.structured_output]
```

Key benefits:

- **Type Safety**: Get typed objects instead of raw strings
- **Automatic Validation**: Schema validation ensures responses match your structure
- **Clear Documentation**: Schema serves as documentation of expected output
- **IDE Support**: IDE type hinting from LLM-generated responses
- **Error Prevention**: Catch malformed responses early

## Basic Usage

[Section titled “Basic Usage”](#basic-usage)

Define an output structure using a schema. In Python, use a Pydantic model and pass it to `structured_output_model`. In TypeScript, use a Zod schema and pass it to `structuredOutputSchema`. Then, access the validated output from the `AgentResult`.

- [Python](#tab-panel-1484)
- [TypeScript](#tab-panel-1485)

```
from pydantic import BaseModel, Field


from strands import Agent


# 1) Define the Pydantic model


class PersonInfo(BaseModel):


"""Model that contains information about a Person"""


name: str = Field(description="Name of the person")


age: int = Field(description="Age of the person")


occupation: str = Field(description="Occupation of the person")


# 2) Pass the model to the agent


agent = Agent()


result = agent(


"John Smith is a 30 year-old software engineer",


structured_output_model=PersonInfo


)


# 3) Access the `structured_output` from the result


person_info: PersonInfo = result.structured_output


print(f"Name: {person_info.name}")      # "John Smith"


print(f"Age: {person_info.age}")        # 30


print(f"Job: {person_info.occupation}") # "software engineer"
```

```
// 1) Define the Zod schema


const PersonSchema = z.object({


name: z.string().describe('Name of the person'),


age: z.number().describe('Age of the person'),


occupation: z.string().describe('Occupation of the person'),


})


type Person = z.infer<typeof PersonSchema>


// 2) Pass the schema to the agent


const agent = new Agent({


structuredOutputSchema: PersonSchema,


})


const result = await agent.invoke('John Smith is a 30 year-old software engineer')


// 3) Access the `structuredOutput` from the result


// TypeScript infers the type from the schema


const person = result.structuredOutput as Person


console.log(`Name: ${person.name}`) // "John Smith"


console.log(`Age: ${person.age}`) // 30


console.log(`Job: ${person.occupation}`) // "software engineer"
```

## More Information

[Section titled “More Information”](#more-information)

### How It Works

[Section titled “How It Works”](#how-it-works)

The structured output system converts your schema definitions into tool specifications that guide the language model to produce correctly formatted responses. All of the model providers supported in Strands can work with Structured Output.

In Python, Strands accepts the `structured_output_model` parameter in agent invocations, which manages the conversion, validation, and response processing automatically. In TypeScript, the `structuredOutputSchema` parameter (either at agent initialization or per-invocation) handles this process. The validated result is available in the `AgentResult.structured_output` (Python) or `AgentResult.structuredOutput` (TypeScript) field.

### Error Handling

[Section titled “Error Handling”](#error-handling)

When structured output validation fails, Strands throws a custom exception that can be caught and handled appropriately:

- [Python](#tab-panel-1488)
- [TypeScript](#tab-panel-1489)

```
from pydantic import ValidationError


from strands.types.exceptions import StructuredOutputException


try:


result = agent(prompt, structured_output_model=MyModel)


except StructuredOutputException as e:


print(f"Structured output failed: {e}")
```

```
try {


const result = await agent.invoke('some prompt')


} catch (error) {


if (error instanceof StructuredOutputError) {


console.log(`Structured output failed: ${error.message}`)


}


}
```

### Migration from Legacy API

[Section titled “Migration from Legacy API”](#migration-from-legacy-api)

#### Before (Deprecated)

[Section titled “Before (Deprecated)”](#before-deprecated)

- [Python](#tab-panel-1480)
- [TypeScript](#tab-panel-1481)

```
# Old approach - deprecated


result = agent.structured_output(PersonInfo, "John is 30 years old")


print(result.name)  # Direct access to model fields
```

```
// No deprecated API in TypeScript
```

#### After (Recommended)

[Section titled “After (Recommended)”](#after-recommended)

- [Python](#tab-panel-1482)
- [TypeScript](#tab-panel-1483)

```
# New approach - recommended


result = agent("John is 30 years old", structured_output_model=PersonInfo)


print(result.structured_output.name)  # Access via structured_output field
```

```
// TypeScript approach


const agent = new Agent({ structuredOutputSchema: PersonSchema })


const result = await agent.invoke('John is 30 years old')


console.log(result.structuredOutput.name)  // Access via structuredOutput field
```

### Best Practices

[Section titled “Best Practices”](#best-practices)

- **Keep schemas focused**: Define specific schemas for clear purposes
- **Use descriptive field names**: Include helpful descriptions with field metadata
- **Handle errors gracefully**: Implement proper error handling strategies with fallbacks

### Related Documentation

[Section titled “Related Documentation”](#related-documentation)

For Python, refer to Pydantic documentation:

- [Models and schema definition](https://docs.pydantic.dev/latest/concepts/models/)
- [Field types and constraints](https://docs.pydantic.dev/latest/concepts/fields/)
- [Custom validators](https://docs.pydantic.dev/latest/concepts/validators/)

For TypeScript, refer to Zod documentation:

- [Zod documentation](https://zod.dev/)
- [Schema types](https://zod.dev/?id=primitives)
- [Schema methods](https://zod.dev/?id=strings)

## Cookbook

[Section titled “Cookbook”](#cookbook)

### Auto Retries with Validation

[Section titled “Auto Retries with Validation”](#auto-retries-with-validation)

Automatically retry validation when initial extraction fails due to schema validation:

- [Python](#tab-panel-1490)
- [TypeScript](#tab-panel-1491)

```
from strands.agent import Agent


from pydantic import BaseModel, field_validator


class Name(BaseModel):


first_name: str


@field_validator("first_name")


@classmethod


def validate_first_name(cls, value: str) -> str:


if not value.endswith('abc'):


raise ValueError("You must append 'abc' to the end of my name")


return value


agent = Agent()


result = agent("What is Aaron's name?", structured_output_model=Name)
```

```
const NameSchema = z.object({


firstName: z.string().refine((val) => val.endsWith('abc'), {


message: "You must append 'abc' to the end of my name",


}),


})


const agent = new Agent({ structuredOutputSchema: NameSchema })


const result = await agent.invoke("What is Aaron's name?")
```

### Streaming Structured Output

[Section titled “Streaming Structured Output”](#streaming-structured-output)

Stream agent execution while using structured output. The structured output is available in the final result:

- [Python](#tab-panel-1492)
- [TypeScript](#tab-panel-1493)

```
from strands import Agent


from pydantic import BaseModel, Field


class WeatherForecast(BaseModel):


"""Weather forecast data."""


location: str


temperature: int


condition: str


humidity: int


wind_speed: int


forecast_date: str


streaming_agent = Agent()


async for event in streaming_agent.stream_async(


"Generate a weather forecast for Seattle: 68°F, partly cloudy, 55% humidity, 8 mph winds, for tomorrow",


structured_output_model=WeatherForecast


):


if "data" in event:


print(event["data"], end="", flush=True)


elif "result" in event:


print(f'The forecast for today is: {event["result"].structured_output}')
```

```
const WeatherForecastSchema = z.object({


location: z.string(),


temperature: z.number(),


condition: z.string(),


humidity: z.number(),


windSpeed: z.number(),


forecastDate: z.string(),


})


type WeatherForecast = z.infer<typeof WeatherForecastSchema>


const agent = new Agent({ structuredOutputSchema: WeatherForecastSchema })


for await (const event of agent.stream(


'Generate a weather forecast for Seattle: 68°F, partly cloudy, 55% humidity, 8 mph winds, for tomorrow'


)) {


if (event.type === 'agentResultEvent') {


const forecast = event.result.structuredOutput as WeatherForecast


console.log(`The forecast is: ${JSON.stringify(forecast)}`)


}


}
```

### Combining with Tools

[Section titled “Combining with Tools”](#combining-with-tools)

Combine structured output with tool usage to format tool execution results:

- [Python](#tab-panel-1494)
- [TypeScript](#tab-panel-1495)

```
from strands import Agent


from strands_tools import calculator


from pydantic import BaseModel, Field


class MathResult(BaseModel):


operation: str = Field(description="the performed operation")


result: int = Field(description="the result of the operation")


tool_agent = Agent(


tools=[calculator]


)


res = tool_agent("What is 42 + 8", structured_output_model=MathResult)
```

```
const calculatorTool = tool({


name: 'calculator',


description: 'Perform basic arithmetic operations',


inputSchema: z.object({


operation: z.enum(['add', 'subtract', 'multiply', 'divide']),


a: z.number(),


b: z.number(),


}),


callback: (input) => {


const ops = {


add: input.a + input.b,


subtract: input.a - input.b,


multiply: input.a * input.b,


divide: input.a / input.b,


}


return ops[input.operation]


},


})


const MathResultSchema = z.object({


operation: z.string().describe('the performed operation'),


result: z.number().describe('the result of the operation'),


})


const agent = new Agent({


tools: [calculatorTool],


structuredOutputSchema: MathResultSchema,


})


const result = await agent.invoke('What is 42 + 8')
```

### Multiple Output Types

[Section titled “Multiple Output Types”](#multiple-output-types)

Reuse a single agent instance with different structured output schemas for varied extraction tasks:

- [Python](#tab-panel-1496)
- [TypeScript](#tab-panel-1497)

```
from strands import Agent


from pydantic import BaseModel, Field


from typing import Optional


class Person(BaseModel):


"""A person's basic information"""


name: str = Field(description="Full name")


age: int = Field(description="Age in years", ge=0, le=150)


email: str = Field(description="Email address")


phone: Optional[str] = Field(description="Phone number", default=None)


class Task(BaseModel):


"""A task or todo item"""


title: str = Field(description="Task title")


description: str = Field(description="Detailed description")


priority: str = Field(description="Priority level: low, medium, high")


completed: bool = Field(description="Whether task is completed", default=False)


agent = Agent()


person_res = agent("Extract person: John Doe, 35, john@test.com", structured_output_model=Person)


task_res = agent("Create task: Review code, high priority, completed", structured_output_model=Task)
```

```
const PersonSchema = z.object({


name: z.string().describe('Full name'),


age: z.number().min(0).max(150).describe('Age in years'),


email: z.string().email().describe('Email address'),


phone: z.string().optional().describe('Phone number'),


})


const TaskSchema = z.object({


title: z.string().describe('Task title'),


description: z.string().describe('Detailed description'),


priority: z.enum(['low', 'medium', 'high']).describe('Priority level'),


completed: z.boolean().default(false).describe('Whether task is completed'),


})


type Person = z.infer<typeof PersonSchema>


type Task = z.infer<typeof TaskSchema>


const personAgent = new Agent({ structuredOutputSchema: PersonSchema })


const taskAgent = new Agent({ structuredOutputSchema: TaskSchema })


const personResult = await personAgent.invoke(


'Extract person: John Doe, 35, john@test.com'


)


const taskResult = await taskAgent.invoke(


'Create task: Review code, high priority, completed'


)
```

### Using Conversation History

[Section titled “Using Conversation History”](#using-conversation-history)

Extract structured information from prior conversation context without repeating questions:

- [Python](#tab-panel-1498)
- [TypeScript](#tab-panel-1499)

```
from strands import Agent


from pydantic import BaseModel


from typing import Optional


agent = Agent()


# Build up conversation context


agent("What do you know about Paris, France?")


agent("Tell me about the weather there in spring.")


class CityInfo(BaseModel):


city: str


country: str


population: Optional[int] = None


climate: str


# Extract structured information from the conversation


result = agent(


"Extract structured information about Paris from our conversation",


structured_output_model=CityInfo


)


print(f"City: {result.structured_output.city}")     # "Paris"


print(f"Country: {result.structured_output.country}") # "France"
```

```
const CityInfoSchema = z.object({


city: z.string(),


country: z.string(),


population: z.number().optional(),


climate: z.string(),


})


type CityInfo = z.infer<typeof CityInfoSchema>


const agent = new Agent({ structuredOutputSchema: CityInfoSchema })


// Build up conversation context


await agent.invoke('What do you know about Paris, France?')


await agent.invoke('Tell me about the weather there in spring.')


// Extract structured information from the conversation


const result = await agent.invoke(


'Extract structured information about Paris from our conversation'


)


const cityInfo = result.structuredOutput as CityInfo


console.log(`City: ${cityInfo.city}`) // "Paris"


console.log(`Country: ${cityInfo.country}`) // "France"
```

### Agent-Level Defaults

[Section titled “Agent-Level Defaults”](#agent-level-defaults)

You can also set a default structured output schema that applies to all agent invocations:

- [Python](#tab-panel-1500)
- [TypeScript](#tab-panel-1501)

```
class PersonInfo(BaseModel):


name: str


age: int


occupation: str


# Set default structured output model for all invocations


agent = Agent(structured_output_model=PersonInfo)


result = agent("John Smith is a 30 year-old software engineer")


print(f"Name: {result.structured_output.name}")      # "John Smith"


print(f"Age: {result.structured_output.age}")        # 30


print(f"Job: {result.structured_output.occupation}") # "software engineer"
```

```
const PersonSchema = z.object({


name: z.string(),


age: z.number(),


occupation: z.string(),


})


type Person = z.infer<typeof PersonSchema>


// Set default structured output schema for all invocations


const agent = new Agent({ structuredOutputSchema: PersonSchema })


const result = await agent.invoke('John Smith is a 30 year-old software engineer')


const person = result.structuredOutput as Person


console.log(`Name: ${person.name}`) // "John Smith"


console.log(`Age: ${person.age}`) // 30


console.log(`Job: ${person.occupation}`) // "software engineer"
```

### Overriding Agent Defaults

[Section titled “Overriding Agent Defaults”](#overriding-agent-defaults)

Even when you set a default schema at the agent initialization level, you can override it for specific invocations:

- [Python](#tab-panel-1502)
- [TypeScript](#tab-panel-1503)

```
class PersonInfo(BaseModel):


name: str


age: int


occupation: str


class CompanyInfo(BaseModel):


name: str


industry: str


employees: int


# Agent with default PersonInfo model


agent = Agent(structured_output_model=PersonInfo)


# Override with CompanyInfo for this specific call


result = agent(


"TechCorp is a software company with 500 employees",


structured_output_model=CompanyInfo


)


print(f"Company: {result.structured_output.name}")      # "TechCorp"


print(f"Industry: {result.structured_output.industry}") # "software"


print(f"Size: {result.structured_output.employees}")    # 500
```

```
const PersonSchema = z.object({


name: z.string(),


age: z.number(),


occupation: z.string(),


})


const CompanySchema = z.object({


name: z.string(),


industry: z.string(),


employees: z.number(),


})


type Company = z.infer<typeof CompanySchema>


// Agent with default PersonInfo schema


const personAgent = new Agent({ structuredOutputSchema: PersonSchema })


// Create a new agent with CompanyInfo schema for this specific use case


const companyAgent = new Agent({ structuredOutputSchema: CompanySchema })


const result = await companyAgent.invoke(


'TechCorp is a software company with 500 employees'


)


const company = result.structuredOutput as Company


console.log(`Company: ${company.name}`) // "TechCorp"


console.log(`Industry: ${company.industry}`) // "software"


console.log(`Size: ${company.employees}`) // 500
```
