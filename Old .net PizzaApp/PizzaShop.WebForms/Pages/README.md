# Pages Folder

This folder contains all ASP.NET Web Forms pages (.aspx and .aspx.cs files) that make up the user interface of the pizza shop application.

## Purpose

Web Forms pages represent the presentation layer using the classic ASP.NET page model with:
- `.aspx` files: Markup with server controls
- `.aspx.cs` files: Code-behind with event handlers and business logic

## Pages in This Folder

- **Default.aspx** - Home page/landing page
- **Menu.aspx** - Browse pre-made pizzas
- **BuildPizza.aspx** - Custom pizza builder interface
- **Cart.aspx** - Shopping cart and checkout

## Legacy Patterns to Note

### ViewState
Each page uses ViewState to maintain control state across postbacks. This results in large hidden fields in the rendered HTML.

```
LEGACY PATTERN: ViewState stores page and control state on the client
MODERNIZATION PATH: Blazor component state or client-side state management
```

### Postback Model
User interactions trigger full page postbacks to the server, even for simple UI updates.

```
LEGACY PATTERN: Postback lifecycle for all server control events
MODERNIZATION PATH: SPA with client-side routing and AJAX
```

### Code-Behind Pattern
Business logic is tightly coupled to UI in code-behind files, making testing difficult.

```
LEGACY PATTERN: Code-behind with direct instantiation
MODERNIZATION PATH: Separation of concerns with dependency injection
```

## Key Technologies

- ASP.NET Web Forms Server Controls (GridView, Repeater, DropDownList, etc.)
- UpdatePanel for AJAX-like behavior
- ValidationControls for server-side validation
- Master pages for consistent layout

## Modernization Priority

**HIGH** - Web Forms pages are the primary modernization target, replacing with Blazor components or Razor Pages.
