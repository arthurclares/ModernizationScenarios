# Scripts Folder

This folder contains JavaScript files for client-side functionality.

## Purpose

Provides minimal client-side enhancements while maintaining the classic Web Forms postback model. Most interaction logic remains server-side.

## Files in This Folder

- jQuery 2.2.4 (referenced from CDN)
- Bootstrap 3.3.7 JavaScript (referenced from CDN)
- Custom scripts (if needed for UI enhancements)

## JavaScript Approach

### Minimal Client-Side Logic
Most functionality relies on server-side postbacks rather than client-side JavaScript.

```
LEGACY PATTERN: Server-centric model with minimal JavaScript
MODERNIZATION PATH: Client-side SPA with rich JavaScript/TypeScript
```

### jQuery 2.2.4
Uses jQuery for DOM manipulation and AJAX helpers.

```
LEGACY PATTERN: jQuery-dependent code
MODERNIZATION PATH: Vanilla JavaScript or modern framework (React/Vue)
```

### Global Namespace
Scripts operate in global namespace with no module system.

```
LEGACY PATTERN: Global functions and variables
MODERNIZATION PATH: ES6 modules with import/export
```

## Typical JavaScript Use Cases

- Client-side validation feedback
- UI animations and transitions
- Confirmation dialogs
- Price calculation preview (before postback)
- Bootstrap component initialization

## Legacy Patterns to Note

### No Module System
All scripts loaded via `<script>` tags in specific order with potential conflicts.

```
LEGACY PATTERN: Script tags with order dependencies
MODERNIZATION PATH: Webpack/Vite with ES6 modules
```

### ES5 Syntax
Uses `var`, function declarations, no arrow functions or modern JavaScript features.

```
LEGACY PATTERN: ES5 JavaScript (var, function, callbacks)
MODERNIZATION PATH: ES6+ with const/let, arrow functions, async/await
```

### No Build Process
JavaScript served directly without minification, bundling, or transpilation.

```
LEGACY PATTERN: Raw JavaScript files
MODERNIZATION PATH: Build pipeline with Babel, TypeScript, bundling
```

## Modernization Priority

**MEDIUM** - JavaScript can be modernized independently while maintaining Web Forms, or replaced entirely in SPA transition.

## References

- jQuery CDN: https://code.jquery.com/jquery-2.2.4.min.js
- Bootstrap JS CDN: https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js
