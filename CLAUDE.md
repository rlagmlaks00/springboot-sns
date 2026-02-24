## Project Overview

This is a Spring Boot project for a simple SNS (Social Networking Service) like Twitter.
It is a web application where users can post messages and see a timeline of posts.

## Important Note for AI Agent

As the AI Agent, you **must not** perform any actions or make any changes to the codebase that have not been explicitly instructed by the user. Adhere strictly to the user's commands and avoid proactive modifications or additions.

## General Rules

- Before deleting files, always get developer approval.
- Do not touch `git push`

## Code Style

### Indentation
- Tab size: 2 spaces
- Continuation indent: 4 spaces

### Record/DTO Formatting
- Each validation annotation on a separate line
- Blank line between fields
- Closing parenthesis on a separate line

```java
public record ExampleRequest(
    @NotBlank(message = "Field is required")
    @Size(min = 2, max = 50, message = "Field must be between 2 and 50 characters")
    String field1,

    @NotBlank(message = "Another field is required")
    String field2
) {}
```
