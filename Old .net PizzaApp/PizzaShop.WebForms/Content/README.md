# Content Folder

This folder contains all CSS stylesheets for the application.

## Purpose

Provides custom styling that works alongside Bootstrap 3.3.7 to create a modern-looking pizza shop interface while using legacy Web Forms technology.

## Files in This Folder

- **site.css** - Main custom stylesheet
- Bootstrap 3.3.7 CSS (referenced from CDN in Site.Master)

## Styling Approach

### Bootstrap 3.3.7 Foundation
Uses Bootstrap's grid system, components, and utilities for responsive layout and consistent styling.

```
LEGACY CONSIDERATION: Bootstrap 3.x is end-of-life (2019)
MODERNIZATION PATH: Upgrade to Bootstrap 5.x or modern CSS framework
```

### Custom CSS for Pizza Shop
- Pizza card styling
- Topping selection visual indicators
- Shopping cart table enhancements
- Price display formatting
- Button customization

## Legacy Patterns to Note

### No CSS Preprocessor
Plain CSS without SASS, LESS, or modern tooling.

```
LEGACY PATTERN: Vanilla CSS with no build pipeline
MODERNIZATION PATH: SCSS/SASS with CSS modules or CSS-in-JS
```

### Manual Responsive Design
Responsive breakpoints handled manually with media queries.

```
LEGACY PATTERN: Manual media queries for each component
MODERNIZATION PATH: CSS Grid/Flexbox with modern responsive utilities
```

### No CSS Variables
Hardcoded colors and values throughout the stylesheet.

```
LEGACY PATTERN: Hardcoded values, no CSS custom properties
MODERNIZATION PATH: CSS variables or design tokens
```

## Visual Design Goals

- **Modern appearance** despite legacy stack
- **Clean, professional** pizza shop branding
- **Responsive layout** for desktop and tablet
- **Clear visual hierarchy** for product browsing
- **Intuitive interactions** with visual feedback

## Color Scheme

- Primary: Red/orange tones (pizza theme)
- Secondary: Warm browns (crust/wood oven aesthetic)
- Accents: Green for vegetarian options
- Neutral: Grays for backgrounds and text

## Modernization Priority

**LOW** - CSS can be reused largely as-is, with minor updates for modern practices.
