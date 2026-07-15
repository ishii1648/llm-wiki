# IssueOps: Automate CI/CD (and more!) with GitHub Issues and Actions

**Author:** Nick Alteen (@ncalteen)  
**Date:** March 19, 2025 | Updated March 20, 2025  
**Reading Time:** 10 minutes

---

## What is IssueOps?

IssueOps is the practice of using GitHub Issues, GitHub Actions, and pull requests as an interface for automating workflows. Instead of switching between tools or manually triggering actions, you can use issue comments, labels, and state changes to kick off CI/CD pipelines, assign tasks, and even deploy applications.

Much like ChatOps and ClickOps, IssueOps applies a collection of tools and concepts to GitHub Issues to automate repetitive tasks. The flexibility of issues and their relationship to pull requests create possibilities ranging from managing approvals and deployments to managing a bed and breakfast reservation system.

## So, why use IssueOps?

**Event-driven automation:** IssueOps lets you automate workflows directly from GitHub Issues and pull requests, turning everyday interactions into powerful triggers for GitHub Actions.

**Customization:** No two teams work identically, and IssueOps adapts to your needs. Whether automating bug triage or triggering deployments, you can customize workflows based on event type and provided data.

**Transparency:** All actions on an issue are logged in its timeline, creating an easy-to-follow record of what happened and when.

**Immutability and auditability:** Because IssueOps uses GitHub Issues and pull requests as a source of truth, every action leaves a record. Everything stays structured, automated, and auditable within GitHub.

### Quickstart Guide to IssueOps

1. **Define your triggers** – Identify actions that should kick off workflows, like opening an issue, adding a label, or merging a pull request.

2. **Configure GitHub Actions** – Define what happens when an event occurs using YAML workflow files.

3. **Test and iterate** – Start small, see what works, and expand from there.

Learn more in the [IssueOps repository](https://github.com/issue-ops/docs).

---

## Defining IssueOps Workflows and How They're Like Finite-State Machines

Most IssueOps workflows follow this basic pattern:

1. A user opens an issue and provides information
2. The issue is validated for required information
3. The issue is submitted for processing
4. Approval is requested from an authorized user or team
5. The request is processed and the issue is closed

When designing IssueOps workflows, it's helpful to think of them as **finite-state machines**: models for how objects move through a series of states in response to external events. Depending on defined rules, different actions occur in response to state changes.

An issue is the *object* processed by the state machine. It changes *state* in response to *events*. As the object changes state, certain *actions* may be performed during a *transition*, provided any required conditions (*guards*) are met.

### Key Concepts

**State:** A point in an object's lifecycle that satisfies certain condition(s).

**Event:** An external occurrence that triggers a state change.

**Transition:** A link between two states that causes certain action(s) when traversed.

**Action:** An atomic task performed when a transition occurs.

**Guard:** A condition evaluated when a trigger event occurs. A transition only happens if all guard conditions are met.

---

## Key Concepts Behind State Machines

### States

A *state* defines the current status of an object. As the object transitions through the state machine, it changes states in response to external events. Common states for issues include opened, submitted, approved, denied, and closed.

### Events

An *event* can be any form of interaction with an object and its current state. In IssueOps, events come from both user and GitHub perspectives. Users can create, submit, approve, deny, or process requests. Interactions like adding labels, commenting, or updating milestones change state.

GitHub Actions supports many events that trigger workflows (see [events that trigger workflows](https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows)).

### Transitions

A *transition* is simply the change from one state to another. In a team membership example, a transition occurs when someone opens an issue. When conditions (guards) are met, the state change occurs and processing may take place.

### Guards

*Guards* are conditions that must be verified before an event can trigger a transition. For example:

- A request should not transition to Approved unless an administrator comments `.approve`
- A request should not transition to Denied unless an administrator comments `.deny`

An *unguarded transition* occurs with no conditions, happening immediately.

### Actions

*Actions* are specific tasks performed during a transition. They may affect the object itself. Examples include:

- Notifying administrators that a request has been submitted
- Adding a user to the requested team
- Notifying the user of the outcome

---

## A Real-World Example: Building a Team Membership Workflow with IssueOps

This example focuses on GitHub Actions workflows for automating membership requests and approvals. Additional repository and permissions settings are discussed in the [IssueOps documentation](https://issue-ops.github.io/docs/setup).

### Step 1: Issue Form Template

GitHub issue forms create standardized, formatted issues based on form fields. Combined with the [issue-ops/parser](https://github.com/issue-ops/parser) action, you can extract reliable, machine-readable JSON from issue body Markdown.

```yaml
name: Team Membership Request
description: Submit a new membership request
title: New Team Membership Request
labels:
  - team-membership
body:
  - type: input
    id: team
    attributes:
      label: Team Name
      description: The team name you would like to join
      placeholder: my-team
    validations:
      required: true
```

Issues created using this form produce JSON:

```json
{
  "team": "my-team"
}
```

### Step 2: Issue Validation

With machine-readable issue bodies, additional validation checks ensure information follows established rules. The [issue-ops/validator](https://github.com/issue-ops/validator) action confirms team existence using custom validation scripts.

```javascript
module.exports = async (field) => {
  const { Octokit } = require('@octokit/rest')
  const core = require('@actions/core')

  const github = new Octokit({
    auth: core.getInput('github-token', { required: true })
  })

  try {
    // Check if the team exists
    core.info(`Checking if team '${field}' exists`)

    await github.rest.teams.getByName({
      org: process.env.GITHUB_REPOSITORY_OWNER ?? '',
      team_slug: field
    })

    core.info(`Team '${field}' exists`)
    return 'success'
  } catch (error) {
    if (error.status === 404) {
      // If the team does not exist, return an error message
      core.error(`Team '${field}' does not exist`)
      return `Team '${field}' does not exist`
    } else {
      // Otherwise, something else went wrong...
      throw error
    }
  }
}
```

### Step 3: Issue Workflows

The main workflow triggers when a user creates or edits a team membership request. This workflow validates user inputs and focuses on the *opened* state. Any time an issue is created, edited, or updated, it re-runs validation.

```yaml
name: Process Issue Open/Edit

on:
  issues:
    types:
      - opened
      - edited
      - reopened

permissions:
  contents: read
  id-token: write
  issues: write

jobs:
  validate:
    name: Validate Request
    runs-on: ubuntu-latest

    # This job should only be run on issues with the `team-membership` label.
    if: ${{ contains(github.event.issue.labels.*.name, 'team-membership') }}

    steps:
      # This is required to ensure the issue form template and any validation
      # scripts are included in the workspace.
      - name: Checkout
        id: checkout
        uses: actions/checkout@v4

      # Since this workflow includes custom validation scripts, we need to
      # install Node.js and any dependencies.
      - name: Setup Node.js
        id: setup-node
        uses: actions/setup-node@v4

      # Install dependencies from `package.json`.
      - name: Install Dependencies
        id: install
        run: npm install

      # GitHub App authentication is required if you want to interact with any
      # resources outside the scope of the repository this workflow runs in.
      - name: Get GitHub App Token
        id: token
        uses: actions/create-github-app-token@v1
        with:
          app-id: ${{ vars.ISSUEOPS_APP_ID }}
          private-key: ${{ secrets.ISSUEOPS_APP_PRIVATE_KEY }}
          owner: ${{ github.repository_owner }}

      # Remove any labels and start fresh. This is important because the
      # issue may have been closed and reopened.
      - name: Remove Labels
        id: remove-label
        uses: issue-ops/labeler@v2
        with:
          action: remove
          github_token: ${{ steps.token.outputs.token }}
          labels: |
            validated
            approved
            denied
          issue_number: ${{ github.event.issue.number }}
          repository: ${{ github.repository }}

      # Parse the issue body into machine-readable JSON, so that it can be
      # processed by the rest of the workflow.
      - name: Parse Issue Body
        id: parse
        uses: issue-ops/parser@v4
        with:
          body: ${{ github.event.issue.body }}
          issue-form-template: team-membership.yml
          workspace: ${{ github.workspace }}

      # Validate early and often! Validation should be run any time an issue is
      # interacted with, to ensure that any changes to the issue body are valid.
      - name: Validate Request
        id: validate
        uses: issue-ops/validator@v3
        with:
          add-comment: true
          github-token: ${{ steps.token.outputs.token }}
          issue-form-template: team-membership.yml
          issue-number: ${{ github.event.issue.number }}
          parsed-issue-body: ${{ steps.parse.outputs.json }}
          workspace: ${{ github.workspace }}

      # If validation passes, add the validated label to the issue.
      - if: ${{ steps.validate.outputs.result == 'success' }}
        name: Add Validated Label
        id: add-label
        uses: issue-ops/labeler@v2
        with:
          action: add
          github_token: ${{ steps.token.outputs.token }}
          labels: |
            validated
          issue_number: ${{ github.event.issue.number }}
          repository: ${{ github.repository }}

      # The `issue-ops/validator` action will automatically notify the user that
      # the request was validated. However, you can optionally add instruction
      # on what to do next.
      - if: ${{ steps.validate.outputs.result == 'success' }}
        name: Notify User (Success)
        id: notify-success
        uses: peter-evans/create-or-update-comment@v4
        with:
          issue-number: ${{ github.event.issue.number }}
          body: |
            Hello! Your request has been validated successfully!

            Please comment with `.submit` to submit this request.
```

### Step 4: Issue Comment Workflows

Once the issue is created, further processing is triggered using issue comments. This can be done with one workflow, but we'll break it into separate workflows for clarity.

#### Submit Workflow

This workflow handles user submission, validating the issue body hasn't been modified.

```yaml
name: Process Submit Comment

on:
  issue_comment:
    types:
      - created

permissions:
  contents: read
  id-token: write
  issues: write

jobs:
  submit:
    name: Submit Request
    runs-on: ubuntu-latest

    # This job should only be run when the following conditions are true:
    #
    # - A user comments `.submit` on the issue.
    # - The issue has the `team-membership` label.
    # - The issue has the `validated` label.
    # - The issue does not have the `approved` or `denied` labels.
    # - The issue is open.
    if: |
      startsWith(github.event.comment.body, '.submit') &&
      contains(github.event.issue.labels.*.name, 'team-membership') == true &&
      contains(github.event.issue.labels.*.name, 'approved') == false &&
      contains(github.event.issue.labels.*.name, 'denied') == false &&
      github.event.issue.state == 'open'

    steps:
      # First, we are going to re-run validation. This is important because
      # the issue body may have changed since the last time it was validated.

      # This is required to ensure the issue form template and any validation
      # scripts are included in the workspace.
      - name: Checkout
        id: checkout
        uses: actions/checkout@v4

      # Since this workflow includes custom validation scripts, we need to
      # install Node.js and any dependencies.
      - name: Setup Node.js
        id: setup-node
        uses: actions/setup-node@v4

      # Install dependencies from `package.json`.
      - name: Install Dependencies
        id: install
        run: npm install

      # GitHub App authentication is required if you want to interact with any
      # resources outside the scope of the repository this workflow runs in.
      - name: Get GitHub App Token
        id: token
        uses: actions/create-github-app-token@v1
        with:
          app-id: ${{ vars.ISSUEOPS_APP_ID }}
          private-key: ${{ secrets.ISSUEOPS_APP_PRIVATE_KEY }}
          owner: ${{ github.repository_owner }}

      # Remove the validated label. This will be re-added if validation passes.
      - name: Remove Validated Label
        id: remove-label
        uses: issue-ops/labeler@v2
        with:
          action: remove
          github_token: ${{ steps.token.outputs.token }}
          labels: |
            validated
          issue_number: ${{ github.event.issue.number }}
          repository: ${{ github.repository }}

      # Parse the issue body into machine-readable JSON, so that it can be
      # processed by the rest of the workflow.
      - name: Parse Issue Body
        id: parse
        uses: issue-ops/parser@v4
        with:
          body: ${{ github.event.issue.body }}
          issue-form-template: team-membership.yml
          workspace: ${{ github.workspace }}

      # Validate early and often! Validation should be run any time an issue is
      # interacted with, to ensure that any changes to the issue body are valid.
      - name: Validate Request
        id: validate
        uses: issue-ops/validator@v3
        with:
          add-comment: false # Don't add another validation comment.
          github-token: ${{ steps.token.outputs.token }}
          issue-form-template: team-membership.yml
          issue-number: ${{ github.event.issue.number }}
          parsed-issue-body: ${{ steps.parse.outputs.json }}
          workspace: ${{ github.workspace }}

      # If validation passed, add the validated and submitted labels to the issue.
      - if: ${{ steps.validate.outputs.result == 'success' }}
        name: Add Validated Label
        id: add-label
        uses: issue-ops/labeler@v2
        with:
          action: add
          github_token: ${{ steps.token.outputs.token }}
          labels: |
            validated
            submitted
          issue_number: ${{ github.event.issue.number }}
          repository: ${{ github.repository }}

      # If validation succeeded, alert the administrator team so they can
      # approve or deny the request.
      - if: ${{ steps.validate.outputs.result == 'success' }}
        name: Notify Admin (Success)
        id: notify-success
        uses: peter-evans/create-or-update-comment@v4
        with:
          issue-number: ${{ github.event.issue.number }}
          body: |
            👋 @issue-ops/admins! The request has been validated and is
            ready for your review. Please comment with `.approve` or `.deny`
            to approve or deny this request.
```

#### Deny Workflow

If the request is denied, the user is notified and the issue closes.

```yaml
name: Process Denial Comment

on:
  issue_comment:
    types:
      - created

permissions:
  contents: read
  id-token: write
  issues: write

jobs:
  submit:
    name: Deny Request
    runs-on: ubuntu-latest

    # This job should only be run when the following conditions are true:
    #
    # - A user comments `.deny` on the issue.
    # - The issue has the `team-membership` label.
    # - The issue has the `validated` label.
    # - The issue has the `submitted` label.
    # - The issue does not have the `approved` or `denied` labels.
    # - The issue is open.
    if: |
      startsWith(github.event.comment.body, '.deny') &&
      contains(github.event.issue.labels.*.name, 'team-membership') == true &&
      contains(github.event.issue.labels.*.name, 'submitted') == true &&
      contains(github.event.issue.labels.*.name, 'validated') == true &&
      contains(github.event.issue.labels.*.name, 'approved') == false &&
      contains(github.event.issue.labels.*.name, 'denied') == false &&
      github.event.issue.state == 'open'

    steps:
      # This time, we do not need to re-run validation because the request is
      # being denied. It can just be closed.

      # However, we do need to confirm that the user who commented `.deny` is
      # a member of the administrator team.
      # GitHub App authentication is required if you want to interact with any
      # resources outside the scope of the repository this workflow runs in.
      - name: Get GitHub App Token
        id: token
        uses: actions/create-github-app-token@v1
        with:
          app-id: ${{ vars.ISSUEOPS_APP_ID }}
          private-key: ${{ secrets.ISSUEOPS_APP_PRIVATE_KEY }}
          owner: ${{ github.repository_owner }}

      # Check if the user who commented `.deny` is a member of the
      # administrator team.
      - name: Check Admin Membership
        id: check-admin
        uses: actions/github-script@v7
        with:
          github-token: ${{ steps.token.outputs.token }}
          script: |
            try {
              await github.rest.teams.getMembershipForUserInOrg({
                org: context.repo.owner,
                team_slug: 'admins',
                username: context.actor,
              })
              core.setOutput('member', 'true')
            } catch (error) {
              if (error.status === 404) {
                core.setOutput('member', 'false')
              }
              throw error
            }

      # If the user is not a member of the administrator team, exit the
      # workflow.
      - if: ${{ steps.check-admin.outputs.member == 'false' }}
        name: Exit
        run: exit 0

      # If the user is a member of the administrator team, add the denied label.
      - name: Add Denied Label
        id: add-label
        uses: issue-ops/labeler@v2
        with:
          action: add
          github_token: ${{ steps.token.outputs.token }}
          labels: |
            denied
          issue_number: ${{ github.event.issue.number }}
          repository: ${{ github.repository }}

      # Notify the user that the request was denied.
      - name: Notify User
        id: notify
        uses: peter-evans/create-or-update-comment@v4
        with:
          issue-number: ${{ github.event.issue.number }}
          body: |
            This request has been denied and will be closed.

      # Close the issue as not planned.
      - name: Close Issue
        id: close
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.update({
              issue_number: ${{ github.event.issue.number }},
              owner: context.repo.owner,
              repo: context.repo.repo,
              state: 'closed',
              state_reason: 'not_planned'
            })
```

#### Approve Workflow

When approved, the user is added to the team, notified, and the issue closes.

```yaml
name: Process Approval Comment

on:
  issue_comment:
    types:
      - created

permissions:
  contents: read
  id-token: write
  issues: write

jobs:
  submit:
    name: Approve Request
    runs-on: ubuntu-latest

    # This job should only be run when the following conditions are true:
    #
    # - A user comments `.approve` on the issue.
    # - The issue has the `team-membership` label.
    # - The issue has the `validated` label.
    # - The issue has the `submitted` label.
    # - The issue does not have the `approved` or `denied` labels.
    # - The issue is open.
    if: |
      startsWith(github.event.comment.body, '.approve') &&
      contains(github.event.issue.labels.*.name, 'team-membership') == true &&
      contains(github.event.issue.labels.*.name, 'submitted') == true &&
      contains(github.event.issue.labels.*.name, 'validated') == true &&
      contains(github.event.issue.labels.*.name, 'approved') == false &&
      contains(github.event.issue.labels.*.name, 'denied') == false &&
      github.event.issue.state == 'open'

    steps:
      # This time, we do not need to re-run validation because the request is
      # being approved. It can just be processed.

      # This is required to ensure the issue form template is included in the
      # workspace.
      - name: Checkout
        id: checkout
        uses: actions/checkout@v4

      # We do need to confirm that the user who commented `.approve` is a member
      # of the administrator team. GitHub App authentication is required if you
      # want to interact with any resources outside the scope of the repository
      # this workflow runs in.
      - name: Get GitHub App Token
        id: token
        uses: actions/create-github-app-token@v1
        with:
          app-id: ${{ vars.ISSUEOPS_APP_ID }}
          private-key: ${{ secrets.ISSUEOPS_APP_PRIVATE_KEY }}
          owner: ${{ github.repository_owner }}

      # Check if the user who commented `.approve` is a member of the
      # administrator team.
      - name: Check Admin Membership
        id: check-admin
        uses: actions/github-script@v7
        with:
          github-token: ${{ steps.token.outputs.token }}
          script: |
            try {
              await github.rest.teams.getMembershipForUserInOrg({
                org: context.repo.owner,
                team_slug: 'admins',
                username: context.actor,
              })
              core.setOutput('member', 'true')
            } catch (error) {
              if (error.status === 404) {
                core.setOutput('member', 'false')
              }
              throw error
            }

      # If the user is not a member of the administrator team, exit the
      # workflow.
      - if: ${{ steps.check-admin.outputs.member == 'false' }}
        name: Exit
        run: exit 0

      # Parse the issue body into machine-readable JSON, so that it can be
      # processed by the rest of the workflow.
      - name: Parse Issue body
        id: parse
        uses: issue-ops/parser@v4
        with:
          body: ${{ github.event.issue.body }}
          issue-form-template: team-membership.yml
          workspace: ${{ github.workspace }}

      - name: Add to Team
        id: add
        uses: actions/github-script@v7
        with:
          github-token: ${{ steps.token.outputs.token }}
          script: |
            const parsedIssue = JSON.parse('${{ steps.parse.outputs.json }}')

            await github.rest.teams.addOrUpdateMembershipForUserInOrg({
              org: context.repo.owner,
              team_slug: parsedIssue.team,
              username: '${{ github.event.issue.user.login }}',
              role: 'member'
            })

      - name: Notify User
        id: notify
        uses: peter-evans/create-or-update-comment@v4
        with:
          issue-number: ${{ github.event.issue.number }}
          body: |
            This request has been processed successfully!

      - name: Close Issue
        id: close
        uses: actions/github-script@v7
        with:
          script: |
            await github.rest.issues.update({
              issue_number: ${{ github.event.issue.number }},
              owner: context.repo.owner,
              repo: context.repo.repo,
              state: 'closed',
              state_reason: 'completed'
            })
```

---

## Take This With You

With a handful of standardized workflows, you have an end-to-end, issue-driven process for managing team membership. This can be extended to support removing users, auditing access, and more.

IssueOps brings automation to a surface developers constantly use—GitHub. By using issues and pull requests as control centers for workflows, teams can reduce friction, improve efficiency, and maintain transparency. Whether automating deployments, approvals, or bug triage, IssueOps makes it possible without leaving your repository.

For more information and examples, check out the open source [IssueOps documentation repository](https://github.com/issue-ops/docs). For a deeper dive, visit the [IssueOps documentation](https://issue-ops.github.io/docs/).

Start small and experiment with what works best for your team. With time, you'll see workflows become smoother with every commit. Happy coding! ✨

---

**Tags:** GitHub Issues, IssueOps, Pull Requests
