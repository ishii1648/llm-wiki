<!-- source: https://strandsagents.com/docs/user-guide/evals-sdk/how-to/experiment_management/ -->
<!-- title: Experiment Management -->

# Experiment Management

## Overview

[Section titled “Overview”](#overview)

Test cases in Strands Evals are organized into `Experiment` objects. This guide covers practical patterns for managing experiments and test cases.

## Organizing Test Cases

[Section titled “Organizing Test Cases”](#organizing-test-cases)

### Using Metadata for Organization

[Section titled “Using Metadata for Organization”](#using-metadata-for-organization)

```
from strands_evals import Case


# Add metadata for filtering and organization


cases = [


Case(


name="easy-math",


input="What is 2 + 2?",


metadata={


"category": "math",


"difficulty": "easy",


"tags": ["arithmetic"]


}


),


Case(


name="hard-math",


input="Solve x^2 + 5x + 6 = 0",


metadata={


"category": "math",


"difficulty": "hard",


"tags": ["algebra"]


}


)


]


# Filter by metadata


easy_cases = [c for c in cases if c.metadata.get("difficulty") == "easy"]
```

### Naming Conventions

[Section titled “Naming Conventions”](#naming-conventions)

```
# Pattern: {category}-{subcategory}-{number}


Case(name="knowledge-geography-001", input="..."),


Case(name="math-arithmetic-001", input="..."),
```

## Managing Multiple Experiments

[Section titled “Managing Multiple Experiments”](#managing-multiple-experiments)

### Experiment Collections

[Section titled “Experiment Collections”](#experiment-collections)

```
from strands_evals import Experiment


experiments = {


"baseline": Experiment(cases=baseline_cases, evaluators=[...]),


"with_tools": Experiment(cases=tool_cases, evaluators=[...]),


"edge_cases": Experiment(cases=edge_cases, evaluators=[...])


}


# Run all


for name, exp in experiments.items():


print(f"Running {name}...")


reports = exp.run_evaluations(task_function)
```

### Combining Experiments

[Section titled “Combining Experiments”](#combining-experiments)

```
# Merge cases from multiple experiments


combined = Experiment(


cases=exp1.cases + exp2.cases + exp3.cases,


evaluators=[OutputEvaluator()]


)
```

### Flattening Reports

[Section titled “Flattening Reports”](#flattening-reports)

When running multiple evaluators, you get one report per evaluator. Use `EvaluationReport.flatten` to combine them into a single view:

```
reports = experiment.run_evaluations(task_function)


from strands_evals.types.evaluation_report import EvaluationReport


combined = EvaluationReport.flatten(reports)


combined.run_display()  # Shows all evaluators in one table
```

## Modifying Experiments

[Section titled “Modifying Experiments”](#modifying-experiments)

### Adding Cases

[Section titled “Adding Cases”](#adding-cases)

```
# Add single case


experiment.cases.append(new_case)


# Add multiple


experiment.cases.extend(additional_cases)
```

### Updating Evaluators

[Section titled “Updating Evaluators”](#updating-evaluators)

```
from strands_evals.evaluators import HelpfulnessEvaluator


# Replace evaluators


experiment.evaluators = [


OutputEvaluator(),


HelpfulnessEvaluator()


]
```

## Session IDs

[Section titled “Session IDs”](#session-ids)

Each case gets a unique session ID automatically:

```
case = Case(input="test")


print(case.session_id)  # Auto-generated UUID


# Or provide custom


case = Case(input="test", session_id="custom-123")
```

## Best Practices

[Section titled “Best Practices”](#best-practices)

### 1. Use Descriptive Names

[Section titled “1. Use Descriptive Names”](#1-use-descriptive-names)

```
# Good


Case(name="customer-service-refund-request", input="...")


# Less helpful


Case(name="test1", input="...")
```

### 2. Include Rich Metadata

[Section titled “2. Include Rich Metadata”](#2-include-rich-metadata)

```
Case(


name="complex-query",


input="...",


metadata={


"category": "customer_service",


"difficulty": "medium",


"expected_tools": ["search_orders"],


"created_date": "2025-01-15"


}


)
```

### 3. Version Your Experiments

[Section titled “3. Version Your Experiments”](#3-version-your-experiments)

```
experiment.to_file("experiment_v1.json")


experiment.to_file("experiment_v2.json")


# Or with timestamps


from datetime import datetime


timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")


experiment.to_file(f"experiment_{timestamp}.json")
```

## Related Documentation

[Section titled “Related Documentation”](#related-documentation)

- [Serialization](/docs/user-guide/evals-sdk/how-to/serialization/): Save and load experiments
- [Experiment Generator](/docs/user-guide/evals-sdk/experiment_generator/): Generate experiments automatically
- [Quickstart Guide](/docs/user-guide/evals-sdk/quickstart/): Get started with experiments
